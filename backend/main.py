import os
import sqlite3

import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


DATABASE_NAME = "kisansetu.db"


class FarmPlan(BaseModel):
    crop_name: str
    farm_area: str
    activity: str
    sowing_date: str
    harvest_date: str
    notes: str


def create_database():
    connection = sqlite3.connect(DATABASE_NAME)
    cursor = connection.cursor()

    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS farm_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop_name TEXT NOT NULL,
            farm_area TEXT NOT NULL,
            activity TEXT NOT NULL,
            sowing_date TEXT NOT NULL,
            harvest_date TEXT NOT NULL,
            notes TEXT
        )
        """
    )

    connection.commit()
    connection.close()


create_database()


@app.get("/")
def home():
    return {
        "message": "Welcome to KisanSetu backend"
    }


@app.post("/farm-plans")
def create_farm_plan(plan: FarmPlan):
    connection = sqlite3.connect(DATABASE_NAME)
    cursor = connection.cursor()

    cursor.execute(
        """
        INSERT INTO farm_plans
        (
            crop_name,
            farm_area,
            activity,
            sowing_date,
            harvest_date,
            notes
        )
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (
            plan.crop_name,
            plan.farm_area,
            plan.activity,
            plan.sowing_date,
            plan.harvest_date,
            plan.notes,
        ),
    )

    connection.commit()
    connection.close()

    return {
        "message": "Farm plan saved permanently",
        "plan": plan,
    }


@app.get("/farm-plans")
def get_farm_plans():
    connection = sqlite3.connect(DATABASE_NAME)
    connection.row_factory = sqlite3.Row
    cursor = connection.cursor()

    cursor.execute(
        """
        SELECT
            id,
            crop_name,
            farm_area,
            activity,
            sowing_date,
            harvest_date,
            notes
        FROM farm_plans
        ORDER BY id DESC
        """
    )

    rows = cursor.fetchall()
    connection.close()

    return [dict(row) for row in rows]


@app.get("/weather")
def get_weather(city: str = "Hyderabad"):
    api_key = os.getenv("OPENWEATHER_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="OpenWeatherMap API key is not configured",
        )

    weather_url = "https://api.openweathermap.org/data/2.5/weather"

    parameters = {
        "q": city,
        "appid": api_key,
        "units": "metric",
    }

    try:
        response = requests.get(
            weather_url,
            params=parameters,
            timeout=10,
        )

        if response.status_code == 401:
            raise HTTPException(
                status_code=401,
                detail="Invalid OpenWeatherMap API key",
            )

        if response.status_code == 404:
            raise HTTPException(
                status_code=404,
                detail="City not found",
            )

        response.raise_for_status()

        data = response.json()

        return {
            "city": data["name"],
            "country": data["sys"]["country"],
            "temperature": data["main"]["temp"],
            "feels_like": data["main"]["feels_like"],
            "humidity": data["main"]["humidity"],
            "pressure": data["main"]["pressure"],
            "wind_speed": data["wind"]["speed"],
            "weather": data["weather"][0]["main"],
            "description": data["weather"][0]["description"],
            "icon": data["weather"][0]["icon"],
        }

    except requests.exceptions.Timeout:
        raise HTTPException(
            status_code=504,
            detail="Weather service took too long to respond",
        )

    except requests.exceptions.RequestException:
        raise HTTPException(
            status_code=502,
            detail="Could not connect to weather service",
        )
    
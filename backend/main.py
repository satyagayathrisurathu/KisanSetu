import os
import sqlite3
from typing import Any

import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

DATABASE_NAME = 'kisansetu.db'

app = FastAPI(title='KisanSetu Backend')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


def get_connection() -> sqlite3.Connection:
    connection = sqlite3.connect(DATABASE_NAME)
    connection.row_factory = sqlite3.Row
    return connection


def init_db() -> None:
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        '''
        CREATE TABLE IF NOT EXISTS farm_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop_name TEXT NOT NULL,
            farm_area TEXT NOT NULL,
            activity TEXT NOT NULL,
            sowing_date TEXT NOT NULL,
            harvest_date TEXT NOT NULL,
            notes TEXT DEFAULT ''
        )
        '''
    )

    cursor.execute(
        '''
        CREATE TABLE IF NOT EXISTS workers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            role TEXT NOT NULL,
            language TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'Available'
        )
        '''
    )

    cursor.execute(
        '''
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            worker_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            crop TEXT NOT NULL,
            task_date TEXT NOT NULL,
            location TEXT NOT NULL,
            payment TEXT NOT NULL,
            notes TEXT DEFAULT '',
            status TEXT NOT NULL DEFAULT 'Assigned'
        )
        '''
    )

    cursor.execute(
        '''
        CREATE TABLE IF NOT EXISTS machinery (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            owner TEXT NOT NULL,
            location TEXT NOT NULL,
            rate INTEGER NOT NULL,
            unit TEXT NOT NULL DEFAULT 'hour',
            status TEXT NOT NULL DEFAULT 'Available'
        )
        '''
    )

    cursor.execute(
        '''
        CREATE TABLE IF NOT EXISTS machinery_bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            machinery_id INTEGER NOT NULL,
            machinery_name TEXT NOT NULL,
            booking_date TEXT NOT NULL,
            farm_location TEXT NOT NULL,
            hours INTEGER NOT NULL,
            total_cost INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'Booked'
        )
        '''
    )

    count = cursor.execute('SELECT COUNT(*) AS count FROM machinery').fetchone()['count']
    if count == 0:
        cursor.executemany(
            '''
            INSERT INTO machinery (name, type, owner, location, rate, unit, status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ''',
            [
                (
                    'Mahindra Tractor',
                    'Tractor',
                    'Ravi Machinery Services',
                    'Test Village',
                    1200,
                    'hour',
                    'Available',
                ),
                (
                    'Rotavator',
                    'Tillage machine',
                    'Green Farm Equipment',
                    'Main Road',
                    900,
                    'hour',
                    'Available',
                ),
                (
                    'Paddy Harvester',
                    'Harvester',
                    'Sita Agro Services',
                    'North Field',
                    2500,
                    'hour',
                    'Available',
                ),
            ],
        )

    connection.commit()
    connection.close()


@app.on_event('startup')
def startup_event() -> None:
    init_db()


class FarmPlan(BaseModel):
    crop_name: str
    farm_area: str
    activity: str
    sowing_date: str
    harvest_date: str
    notes: str = ''


class Worker(BaseModel):
    name: str
    phone: str
    role: str
    language: str
    status: str = 'Available'


class Task(BaseModel):
    worker_id: int
    title: str
    crop: str
    task_date: str
    location: str
    payment: str
    notes: str = ''


class MachineryBooking(BaseModel):
    booking_date: str
    farm_location: str
    hours: int


def rows_to_dicts(rows: list[sqlite3.Row]) -> list[dict[str, Any]]:
    return [dict(row) for row in rows]


@app.get('/')
def root() -> dict[str, str]:
    return {'message': 'Welcome to KisanSetu backend'}


@app.post('/farm-plans')
def create_farm_plan(plan: FarmPlan) -> dict[str, Any]:
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        '''
        INSERT INTO farm_plans
        (crop_name, farm_area, activity, sowing_date, harvest_date, notes)
        VALUES (?, ?, ?, ?, ?, ?)
        ''',
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
    row = cursor.execute(
        'SELECT * FROM farm_plans WHERE id = ?', (cursor.lastrowid,)
    ).fetchone()
    connection.close()
    return dict(row)


@app.get('/farm-plans')
def get_farm_plans() -> list[dict[str, Any]]:
    connection = get_connection()
    rows = connection.execute('SELECT * FROM farm_plans ORDER BY id DESC').fetchall()
    connection.close()
    return rows_to_dicts(rows)


@app.post('/workers')
def create_worker(worker: Worker) -> dict[str, Any]:
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        '''
        INSERT INTO workers (name, phone, role, language, status)
        VALUES (?, ?, ?, ?, ?)
        ''',
        (worker.name, worker.phone, worker.role, worker.language, worker.status),
    )
    connection.commit()
    row = cursor.execute(
        'SELECT * FROM workers WHERE id = ?', (cursor.lastrowid,)
    ).fetchone()
    connection.close()
    return dict(row)


@app.get('/workers')
def get_workers() -> list[dict[str, Any]]:
    connection = get_connection()
    rows = connection.execute('SELECT * FROM workers ORDER BY id DESC').fetchall()
    connection.close()
    return rows_to_dicts(rows)


@app.delete('/workers/{worker_id}')
def delete_worker(worker_id: int) -> dict[str, str]:
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute('DELETE FROM workers WHERE id = ?', (worker_id,))
    deleted = cursor.rowcount
    connection.commit()
    connection.close()

    if deleted == 0:
        raise HTTPException(status_code=404, detail='Worker not found.')
    return {'message': 'Worker deleted successfully.'}


@app.post('/tasks')
def create_task(task: Task) -> dict[str, Any]:
    connection = get_connection()
    cursor = connection.cursor()

    worker = cursor.execute(
        'SELECT * FROM workers WHERE id = ?', (task.worker_id,)
    ).fetchone()

    if worker is None:
        connection.close()
        raise HTTPException(status_code=404, detail='Worker not found.')

    if worker['status'] != 'Available':
        connection.close()
        raise HTTPException(status_code=400, detail='Worker is currently busy.')

    cursor.execute(
        '''
        INSERT INTO tasks
        (worker_id, title, crop, task_date, location, payment, notes, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'Assigned')
        ''',
        (
            task.worker_id,
            task.title,
            task.crop,
            task.task_date,
            task.location,
            task.payment,
            task.notes,
        ),
    )
    task_id = cursor.lastrowid

    cursor.execute(
        "UPDATE workers SET status = 'Busy' WHERE id = ?", (task.worker_id,)
    )
    connection.commit()

    row = cursor.execute(
        'SELECT * FROM tasks WHERE id = ?', (task_id,)
    ).fetchone()
    connection.close()
    return dict(row)


@app.get('/tasks')
def get_tasks() -> list[dict[str, Any]]:
    connection = get_connection()
    rows = connection.execute('SELECT * FROM tasks ORDER BY id DESC').fetchall()
    connection.close()
    return rows_to_dicts(rows)


@app.put('/tasks/{task_id}/complete')
def complete_task(task_id: int) -> dict[str, Any]:
    connection = get_connection()
    cursor = connection.cursor()
    task = cursor.execute(
        'SELECT * FROM tasks WHERE id = ?', (task_id,)
    ).fetchone()

    if task is None:
        connection.close()
        raise HTTPException(status_code=404, detail='Task not found.')

    cursor.execute(
        "UPDATE tasks SET status = 'Completed' WHERE id = ?", (task_id,)
    )
    cursor.execute(
        "UPDATE workers SET status = 'Available' WHERE id = ?",
        (task['worker_id'],),
    )
    connection.commit()

    row = cursor.execute(
        'SELECT * FROM tasks WHERE id = ?', (task_id,)
    ).fetchone()
    connection.close()
    return dict(row)


@app.get('/machinery')
def get_machinery() -> list[dict[str, Any]]:
    connection = get_connection()
    rows = connection.execute(
        'SELECT * FROM machinery ORDER BY id ASC'
    ).fetchall()
    connection.close()
    return rows_to_dicts(rows)


@app.get('/machinery/bookings')
def get_machinery_bookings() -> list[dict[str, Any]]:
    connection = get_connection()
    rows = connection.execute(
        'SELECT * FROM machinery_bookings ORDER BY id DESC'
    ).fetchall()
    connection.close()
    return rows_to_dicts(rows)


@app.post('/machinery/{machinery_id}/book')
def book_machinery(machinery_id: int, booking: MachineryBooking) -> dict[str, Any]:
    if booking.hours <= 0:
        raise HTTPException(status_code=400, detail='Hours must be greater than zero.')

    connection = get_connection()
    cursor = connection.cursor()

    machine = cursor.execute(
        'SELECT * FROM machinery WHERE id = ?', (machinery_id,)
    ).fetchone()

    if machine is None:
        connection.close()
        raise HTTPException(status_code=404, detail='Machinery not found.')

    if machine['status'] != 'Available':
        connection.close()
        raise HTTPException(status_code=400, detail='Machinery is currently booked.')

    total_cost = machine['rate'] * booking.hours

    cursor.execute(
        '''
        INSERT INTO machinery_bookings
        (machinery_id, machinery_name, booking_date, farm_location, hours, total_cost, status)
        VALUES (?, ?, ?, ?, ?, ?, 'Booked')
        ''',
        (
            machinery_id,
            machine['name'],
            booking.booking_date,
            booking.farm_location,
            booking.hours,
            total_cost,
        ),
    )
    booking_id = cursor.lastrowid

    cursor.execute(
        "UPDATE machinery SET status = 'Booked' WHERE id = ?",
        (machinery_id,),
    )
    connection.commit()

    row = cursor.execute(
        'SELECT * FROM machinery_bookings WHERE id = ?', (booking_id,)
    ).fetchone()
    connection.close()
    return dict(row)


@app.put('/machinery/bookings/{booking_id}/complete')
def complete_machinery_booking(booking_id: int) -> dict[str, Any]:
    connection = get_connection()
    cursor = connection.cursor()

    booking = cursor.execute(
        'SELECT * FROM machinery_bookings WHERE id = ?', (booking_id,)
    ).fetchone()

    if booking is None:
        connection.close()
        raise HTTPException(status_code=404, detail='Machinery booking not found.')

    cursor.execute(
        "UPDATE machinery_bookings SET status = 'Completed' WHERE id = ?",
        (booking_id,),
    )
    cursor.execute(
        "UPDATE machinery SET status = 'Available' WHERE id = ?",
        (booking['machinery_id'],),
    )
    connection.commit()

    row = cursor.execute(
        'SELECT * FROM machinery_bookings WHERE id = ?', (booking_id,)
    ).fetchone()
    connection.close()
    return dict(row)


@app.get('/weather')
def get_weather(city: str = 'Hyderabad') -> dict[str, Any]:
    api_key = os.getenv('OPENWEATHER_API_KEY')
    if not api_key:
        raise HTTPException(
            status_code=500,
            detail='OPENWEATHER_API_KEY is not configured.',
        )

    url = 'https://api.openweathermap.org/data/2.5/weather'
    params = {
        'q': city,
        'appid': api_key,
        'units': 'metric',
    }

    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        return {
            'city': data.get('name', city),
            'temperature': data.get('main', {}).get('temp'),
            'feels_like': data.get('main', {}).get('feels_like'),
            'humidity': data.get('main', {}).get('humidity'),
            'description': (
                data.get('weather', [{}])[0].get('description', '')
            ),
        }
    except requests.RequestException as exc:
        raise HTTPException(
            status_code=502,
            detail=f'Weather service request failed: {exc}',
        ) from exc

FROM python:latest
WORKDIR /app
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY . /app/
RUN django-admin startproject my_project . 
EXPOSE 8000
COPY . /code
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh", "python", "manage.py", "runserver", "0.0.0.0:8000"]

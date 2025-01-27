FROM python:3.9-alpine

ENV PYTHONUNBUFFERED=1

# Install dependencies
RUN apk add --no-cache --virtual .tmp-build-deps \
    gcc libc-dev linux-headers

# Create a virtual environment
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt
COPY requirements.dev.txt /tmp/requirements.dev.txt

RUN apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev

# Set the environment variable
ARG DEV=false

# Install Python dependencies
RUN /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt;  \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps

# Add a non-root user
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Set environment variables
ENV PATH="/py/bin:$PATH"

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . /app

# Run the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
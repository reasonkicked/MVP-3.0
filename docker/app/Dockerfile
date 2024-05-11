FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# List contents of the root directory
RUN ls -la /

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# List contents of the /app directory after copying requirements.txt
RUN ls -la /app

# Copy the source code
COPY ./src/ .

# List contents of the /app directory after copying the src directory
RUN ls -la /app

# Command to run the application
CMD ["python", "app.py"]
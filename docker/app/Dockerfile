FROM python:3.8-slim

# Set the working directory
WORKDIR /app



# Copy the source code
COPY src/ .
# Copy the requirements file and install dependencies

RUN pip install --no-cache-dir -r requirements.txt
# Command to run the application
CMD ["python", "app.py"]
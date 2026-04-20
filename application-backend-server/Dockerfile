FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies (includes pymysql for database connectivity)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .
COPY students.json .

# Expose port 8081
EXPOSE 8081

# Run the Flask application
CMD ["python", "app.py"]

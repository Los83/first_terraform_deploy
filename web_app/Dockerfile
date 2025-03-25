# Use a base image (e.g., Python)
FROM --platform=linux/amd64 python:3.9

# Set the working directory inside the container
WORKDIR /app

# Copy the necessary files into the container
COPY requirements.txt requirements.txt
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port your app will listen on
EXPOSE 80

# Define the command to run when the container starts
CMD ["python", "app.py"]

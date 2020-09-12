version = "1.0"

train {
    step train {
        image = "nvidia/cuda:10.1-cudnn8-devel"
        script = [{sh = ["bash train.sh"]}]
        resources {
            cpu = "1"
            memory = "8G"
            gpu = "1"
        }
    }

    parameters {
        NUM_STEPS = "40000"
        NUM_CLASSES = "4"
        GOOGLE_FILE_ID = "1dfD1k77WL_xFmYXUOZOAqTnRUrtF2FaR"
    }
}

serve {
    image = "python:3.7"
    install = [
        "pip3 install --upgrade pip",
        "pip3 install -r requirements-serve.txt",
    ]
    script = [
        {sh = [
            "gunicorn --config gunicorn_config.py --bind=:${BEDROCK_SERVER_PORT:-8080} --worker-class=gthread --workers=${WORKERS} --timeout=300 --preload serve_http:app"
        ]}
    ]

    parameters {
        WORKERS = "2"
        prometheus_multiproc_dir = "/tmp"
    }
}
version = "1.0"

train {
    step train {
        image = "basisai/workload-standard:v0.2.1"
        script = [{sh = ["bash train.sh"]}]
        resources {
            cpu = "0.5"
            memory = "1G"
            gpu = "1"
        }
    }

    parameters {
        RAW_SUBSCRIBERS_DATA = "gs://bedrock-sample/churn_data/subscribers.gz.parquet"
        RAW_CALLS_DATA = "gs://bedrock-sample/churn_data/all_calls.gz.parquet"
        TEMP_DATA_BUCKET = "gs://span-temp-production/"
        PREPROCESSED_DATA = "churn_data/preprocessed"
        FEATURES_DATA = "churn_data/features.csv"
        LR = "0.05"
        NUM_LEAVES = "10"
        N_ESTIMATORS = "100"
        OUTPUT_MODEL_NAME = "lgb_model.pkl"
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
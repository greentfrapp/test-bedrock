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
        LEARNING_RATE = "0.00261"
        GOOGLE_FILE_ID = "1dfD1k77WL_xFmYXUOZOAqTnRUrtF2FaR"
        DATA_FOLDER = "yolo_data"
    }
}

serve {
    image = "nvidia/cuda:10.1-cudnn8-devel"
    install = [
        "pip3 install -r requirements-serve.txt",
    ]
    script = [{sh = ["bash serve.sh"]}]
    resources {
        cpu = "1"
        memory = "8G"
        gpu = "1"
    }
    parameters {
        NUM_CLASSES = "4"
        GOOGLE_FILE_ID = "1dfD1k77WL_xFmYXUOZOAqTnRUrtF2FaR"
        DATA_FOLDER = "yolo_data"
        WORKERS = "2"
        prometheus_multiproc_dir = "/tmp"
    }
}
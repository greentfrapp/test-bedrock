"""
Script for serving.
"""
import os
import json

from bedrock_client.bedrock.metrics.service import ModelMonitoringService
from flask import Flask, Response, current_app, request
import cv2
from PIL import Image

import darknet.darknet as darknet


DATA_FOLDER = os.environ.get("DATA_FOLDER")
YOLO_VARS = darknet.load_network(
    config_file="darknet/cfg/yolov4-tiny-custom.cfg",
    data_file=f"./darknet/{DATA_FOLDER}/obj.data",
    weights="/artefact/yolov4-tiny-custom_latest.weights",
    batch_size=1,
)


def image_detection(image_path, network, class_names, class_colors, thresh):
    """Run YOLOv4 models."""
    # Darknet doesn't accept numpy images.
    # Create one with image we reuse for each detect
    width = darknet.network_width(network)
    height = darknet.network_height(network)
    darknet_image = darknet.make_image(width, height, 3)

    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image_resized = cv2.resize(image_rgb, (width, height),
                               interpolation=cv2.INTER_LINEAR)

    darknet.copy_image_from_bytes(darknet_image, image_resized.tobytes())
    detections = darknet.detect_image(network, class_names, darknet_image, thresh=thresh)
    image = darknet.draw_boxes(detections, image_resized, class_colors)
    return cv2.cvtColor(image, cv2.COLOR_BGR2RGB), detections


def detect_bbs(png, yolo_vars, threshold=0.25):
    """Helper function to run YOLOv4 model."""
    network, class_names, class_colors = yolo_vars
    image, detections = image_detection(
        png, network, class_names, class_colors, thresh=threshold,
    )
    og_w, og_h = Image.open(png).size
    new_w, new_h, _ = image.shape
    page_bbs = []
    for (label, conf, bb) in detections:
        scaled_bb = [
            (bb[0] - (bb[2] / 2)) / new_w * og_w,
            (bb[1] - (bb[3] / 2)) / new_h * og_h,
            (bb[0] + (bb[2] / 2)) / new_w * og_w,
            (bb[1] + (bb[3] / 2)) / new_h * og_h,
        ]
        page_bbs.append(scaled_bb + [label])
    return page_bbs


# pylint: disable=invalid-name
app = Flask(__name__)


@app.route("/", methods=["POST"])
def predict():
    result = {
        "prediction": detect_bbs(request.files["image"], YOLO_VARS, threshold=0.25)
    }
    return result


@app.before_first_request
def init_background_threads():
    """Global objects with daemon threads will be stopped by gunicorn --preload flag.
    So instantiate them here instead.
    """
    current_app.monitor = ModelMonitoringService()


@app.route("/metrics", methods=["GET"])
def get_metrics():
    """Returns real time feature values recorded by prometheus
    """
    body, content_type = current_app.monitor.export_http(
        params=request.args.to_dict(flat=False),
        headers=request.headers,
    )
    return Response(body, content_type=content_type)


def main():
    """Starts the Http server"""
    app.run()


if __name__ == "__main__":
    main()
from pathlib import Path
import os

import typer
from loguru import logger
from tqdm import tqdm
import pandas as pd

from waste_management.config import PROCESSED_DATA_DIR, RAW_DATA_DIR

app = typer.Typer()


@app.command()
def main(
    input_path: Path = RAW_DATA_DIR,
    output_path: Path = PROCESSED_DATA_DIR / "dataset.csv",
):
    logger.info("Processing dataset...")
    garbage_types = os.listdir(input_path)
    # Initialize an empty list to store image file paths and their respective labels
    data = []

    # Loop through each garbage type and collect its images' file paths
    for garbage_type in tqdm(garbage_types, desc="Processing garbage types"):
        logger.info(f"Processing {garbage_type}...")
        for file in tqdm(os.listdir(os.path.join(input_path, garbage_type))):
            # Append the image file path and its trash type (as a label) to the data list
            data.append((os.path.join(input_path, garbage_type, file), garbage_type))
    
    # Convert the collected data into a DataFrame and save it as a CSV file
    df = pd.DataFrame(data, columns=["filepath", "label"])
    df.to_csv(output_path, index=False)

    logger.success("Processing dataset complete.")


if __name__ == "__main__":
    app()

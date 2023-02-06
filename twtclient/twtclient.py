import os
from pyspark.sql import SparkSession
from utils.crud_nosql import insert_tweet

# Set localhost socket parameters from ther server
HOST = os.environ.get("HOST", "127.0.0.1")
PORT = 9095

# Create Spark session
spark = SparkSession.builder.appName("Twitter Stream Reader").getOrCreate()

# Create streaming DataFrame from local socket
# delimiter added on server side
stream = spark.readStream.format("socket") \
    .option("host", HOST) \
    .option("port", PORT) \
    .option("delimiter", "\n") \
    .load()

query = stream.writeStream.format("console") \
  .option("truncate", False) \
  .outputMode("append") \
  .foreachBatch(insert_tweet)\
  .start() \
  .awaitTermination()


model_path = download_from_azure("container name", "blobl_name", "local_path")
model = pytorch.load(model_path)
prediction = model.predict(data)
save_data_to_db(prediction)
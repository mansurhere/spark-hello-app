package com.spark.hello.job;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.RowFactory;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class SparkHelloJobApplication {
    private static final Logger logger = LoggerFactory.getLogger(SparkHelloJobApplication.class);

    public static void main(String[] args) {
        // Detect the Kubernetes driver pod name (required for executor allocation)
        SparkSession sparkSession = SparkSession.builder()
                .appName("spark-hello-job")
                //.master("local[*]")
                .config("spark.ui.enabled", "true")
                .config("spark.sql.shuffle.partitions", "1")  // Reduced for small data
                .config("spark.sql.adaptive.enabled", "true") // Enable adaptive query execution
                .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
                .getOrCreate();

        System.out.println("Spark session started.");
        logger.info("Spark session started.");

        try {
            System.out.println("System env Values APP_NAME===="+System.getenv("APP_NAME"));
            System.out.println("System env Values APP_VERSION===="+System.getenv("APP_VERSION"));
            System.out.println("System env Values LOCATION===="+System.getenv("LOCATION"));

            sparkSession.sparkContext().setLogLevel("ERROR");
            // Sample data
            List<Row> list = new ArrayList<>();
            list.add(RowFactory.create("Mansur"));
            list.add(RowFactory.create("One"));
            list.add(RowFactory.create("Two"));
            list.add(RowFactory.create("Three"));
            StructType schema = DataTypes.createStructType(
                    List.of(DataTypes.createStructField("test", DataTypes.StringType, true))
            );

            Dataset<Row> data = sparkSession.createDataFrame(list, schema);
            data.show(false);
            data.printSchema();

            long count = data.count();
            System.out.println("Number of records = " + count);
        } catch (Exception e) {
            logger.error("Error during Spark job execution", e);
            e.printStackTrace();
        } finally {
            sparkSession.stop();
            logger.info("Spark session stopped.");
            System.out.println("Spark session stopped.");
        }
    }
}

package com.spark.hello.app;

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
import java.util.Scanner;

public class SparkHelloAppApplication {
    private static final Logger logger = LoggerFactory.getLogger(SparkHelloAppApplication.class);

    public static void main(String[] args) {
        // Detect the Kubernetes driver pod name (required for executor allocation)
        String driverPodName = System.getenv("HOSTNAME");
        if (driverPodName == null) {
            driverPodName = "unknown-driver-pod";
            System.err.println("WARNING: HOSTNAME env variable not set. spark.kubernetes.driver.pod.name will be incorrect.");
        }

        SparkSession sparkSession = SparkSession.builder()
                .appName("spark hello app")
                // Don't set master here; Spark Operator sets it automatically.
                .master("local[*]")
                .config("spark.submit.deployMode", "cluster")
                .config("spark.kubernetes.namespace", "default")  // Update if your namespace is different
                .config("spark.kubernetes.driver.pod.name", driverPodName)
                .config("spark.ui.enabled", "true")
                .config("spark.sql.shuffle.partitions", "2")
                .config("spark.executor.instances", "1")
                .config("spark.executor.memory", "1g")
                .config("spark.driver.memory", "2g")
                .config("spark.executor.cores", "1")
                .config("spark.driver.cores", "2")
                .config("spark.memory.offHeap.enabled", "true")
                .config("spark.memory.offHeap.size", "512m")
                .config("spark.serializer", "org.apache.spark.serializer.JavaSerializer")
                .config("spark.kryoserializer.buffer", "256k")
                .getOrCreate();

        logger.info("Spark session started.");
        System.out.println("Spark started");

        try {
            sparkSession.sparkContext().setLogLevel("ERROR");
            // Sample data
            List<Row> list = new ArrayList<>();
            list.add(RowFactory.create("one"));
            list.add(RowFactory.create("two"));
            list.add(RowFactory.create("three"));
            list.add(RowFactory.create("four"));
            StructType schema = DataTypes.createStructType(
                    List.of(DataTypes.createStructField("test", DataTypes.StringType, true))
            );

            Dataset<Row> data = sparkSession.createDataFrame(list, schema);
            data.show(false);
            data.printSchema();

            long count = data.count();
            System.out.println("Number of records = " + count);
            data.foreachPartition(iterator -> {
                try {
                    System.out.println("Holding driver pod alive for 5 minutes for UI access...");
                    Thread.sleep(5 * 60 * 1000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
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

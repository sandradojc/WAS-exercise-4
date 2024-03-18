package solid;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.io.IOException;

/**
 * A CArtAgO artifact that agent can use to interact with LDP containers in a Solid pod.
 */
public class Pod extends Artifact {

    private String podURL; // the location of the Solid pod 

  /**
   * Method called by CArtAgO to initialize the artifact. 
   *
   * @param podURL The location of a Solid pod
   */
    public void init(String podURL) {
        this.podURL = podURL;
        log("Pod artifact initialized for: " + this.podURL);
    }

  /**
   * CArtAgO operation for creating a Linked Data Platform container in the Solid pod
   *
   * @param containerName The name of the container to be created
   * 
   */
    @OPERATION
    public void createContainer(String containerName) {
        String fullUri = this.podURL + (this.podURL.endsWith("/") ? "" : "/") + containerName + "/";

        String body = "@prefix ldp: <http://www.w3.org/ns/ldp#>.\n"
        + "@prefix dcterms: <http://purl.org/dc/terms/>.\n"
        + "<> a ldp:Container, ldp:BasicContainer;\n"
        + "dcterms:title \"" + containerName + "\";\n"
        + "dcterms:description \"" + containerName + " Container\".";

        HttpRequest request = HttpRequest.newBuilder(URI.create(fullUri))
            .header("Content-Type", "text/turtle")
            .header("Link", "<http://www.w3.org/ns/ldp#BasicContainer>; rel=\"type\"")
            .POST(HttpRequest.BodyPublishers.ofString(body))
            .build();
        
        HttpClient httpClient = HttpClient.newHttpClient();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            log("1. Implement the method createContainer()");
        } catch (IOException | InterruptedException e) {
            log("Exception while creating container: " + e.getMessage());
            Thread.currentThread().interrupt();
        }
    }

  /**
   * CArtAgO operation for publishing data within a .txt file in a Linked Data Platform container of the Solid pod
   * 
   * @param containerName The name of the container where the .txt file resource will be created
   * @param fileName The name of the .txt file resource to be created in the container
   * @param data An array of Object data that will be stored in the .txt file
   */
    @OPERATION
    public void publishData(String containerName, String fileName, Object[] data) {
        String fullUri = this.podURL + "/" + containerName + "/" + fileName;
        String payload = createStringFromArray(data);

        HttpRequest request = HttpRequest.newBuilder(URI.create(fullUri))
            .header("Content-Type", "text/plain")
            .PUT(HttpRequest.BodyPublishers.ofString(payload))
            .build();

        HttpClient httpClient = HttpClient.newHttpClient();
        try {
            httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            log("2. Implement the method publishData()");
        } catch (IOException | InterruptedException e) {
            log("Exception while publishing: " + e.getMessage());
            Thread.currentThread().interrupt();
        }
    }

  /**
   * CArtAgO operation for reading data of a .txt file in a Linked Data Platform container of the Solid pod
   * 
   * @param containerName The name of the container where the .txt file resource is located
   * @param fileName The name of the .txt file resource that holds the data to be read
   * @param data An array whose elements are the data read from the .txt file
   */
    @OPERATION
    public void readData(String containerName, String fileName, OpFeedbackParam<Object[]> data) {
        data.set(readData(containerName, fileName));
    }

  /**
   * Method for reading data of a .txt file in a Linked Data Platform container of the Solid pod
   * 
   * @param containerName The name of the container where the .txt file resource is located
   * @param fileName The name of the .txt file resource that holds the data to be read
   * @return An array whose elements are the data read from the .txt file
   */
    public Object[] readData(String containerName, String fileName) {
        String fullUri = this.podURL + "/" + containerName + "/" + fileName;

        HttpRequest request = HttpRequest.newBuilder(URI.create(fullUri))
            .GET()
            .build();

        try {
            HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
            String responseBody = response.body();
            Object[] dataArray = createArrayFromString(responseBody);
            log("3. Implement the method readData(). Currently, the method returns mock data");
            return dataArray;
        } catch (IOException | InterruptedException e) {
            log("Exception while reading: " + e.getMessage());
            Thread.currentThread().interrupt();
            return new Object[0];
        }
    }

        // Remove the following mock responses once you have implemented the method
        /*
        switch(fileName) {
            case "watchlist.txt":
                Object[] mockWatchlist = new Object[]{"The Matrix", "Inception", "Avengers: Endgame"};
                return mockWatchlist;
            case "sleep.txt":
                Object[] mockSleepData = new Object[]{"6", "7", "5"};
                return mockSleepData;
            case "trail.txt":
                Object[] mockTrailData = new Object[]{"3", "5.5", "5.5"};
                return mockTrailData; 
            default:
                return new Object[0];
        }

    }
*/
  /**
   * Method that converts an array of Object instances to a string, 
   * e.g. the array ["one", 2, true] is converted to the string "one\n2\ntrue\n"
   *
   * @param array The array to be converted to a string
   * @return A string consisting of the string values of the array elements separated by "\n"
   */
    public static String createStringFromArray(Object[] array) {
        StringBuilder sb = new StringBuilder();
        for (Object obj : array) {
            sb.append(obj.toString()).append("\n");
        }
        return sb.toString();
    }

  /**
   * Method that converts a string to an array of Object instances computed by splitting the given string with delimiter "\n"
   * e.g. the string "one\n2\ntrue\n" is converted to the array ["one", "2", "true"]
   *
   * @param str The string to be converted to an array
   * @return An array consisting of string values that occur by splitting the string around "\n"
   */
    public static Object[] createArrayFromString(String str) {
        return str.split("\n");
    }


  /**
   * CArtAgO operation for updating data of a .txt file in a Linked Data Platform container of the Solid pod
   * The method reads the data currently stored in the .txt file and publishes in the file the old data along with new data 
   * 
   * @param containerName The name of the container where the .txt file resource is located
   * @param fileName The name of the .txt file resource that holds the data to be updated
   * @param data An array whose elements are the new data to be added in the .txt file
   */
    @OPERATION
    public void updateData(String containerName, String fileName, Object[] data) {
        Object[] oldData = readData(containerName, fileName);
        Object[] allData = new Object[oldData.length + data.length];
        System.arraycopy(oldData, 0, allData, 0, oldData.length);
        System.arraycopy(data, 0, allData, oldData.length, data.length);
        publishData(containerName, fileName, allData);
    }
}

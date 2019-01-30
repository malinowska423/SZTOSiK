package com.sztosik;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;


public class GUI extends Application {

    private FXMLLoader loader;

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) throws IOException {
        launchLogInScene();
        System.out.println("Ładuję " + LogInControls.appMode);
        loader = new FXMLLoader(getClass().getResource("/fxml/" + LogInControls.appMode));
        Parent root = loader.load();
        primaryStage.setTitle("SZTOSiK");
        primaryStage.setScene(new Scene(root, 1280, 720));
        primaryStage.setResizable(false);
        primaryStage.getIcons().add(new Image(getClass().getResourceAsStream("/images/icon.png")));
        primaryStage.show();
    }

    private void launchLogInScene() throws IOException {
        loader = new FXMLLoader(getClass().getResource("/fxml/logIn.fxml"));
        Parent root = loader.load();
        Stage logInStage = new Stage();
        logInStage.setTitle("SZTOSiK");
        logInStage.setScene(new Scene(root, 780, 550));
        logInStage.setResizable(false);
        logInStage.initModality(Modality.APPLICATION_MODAL);
        logInStage.setOnCloseRequest(windowEvent -> System.exit(0));
        logInStage.getIcons().add(new Image(getClass().getResourceAsStream("/images/icon.png")));
        logInStage.showAndWait();
    }


}

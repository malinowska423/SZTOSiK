package com.sztosik;

import javafx.application.Application;
import javafx.stage.Stage;


public class GUI extends Application {

    private static GUI instance;

    static GUI getInstance() {
        if (instance == null) {
            synchronized (GUI.class) {
                if (instance == null) {
                    instance = new GUI();
                }
            }
        }
        return instance;
    }

    public static void main(String[] args) {

        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {




        primaryStage.show();


    }
}

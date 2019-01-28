package com.sztosik;

import javafx.fxml.FXML;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;

public class StudentControls {
    @FXML
    AnchorPane rightPane;

    @FXML
    HBox filtersPane;

    @FXML
    Pane displayPane;

    @FXML
    void showGrades(){
        System.out.println("Pokazuję oceny ucznia");
    }

    @FXML
    void showSchedule(){
        System.out.println("Pokazuję plan ucznia");
    }
}

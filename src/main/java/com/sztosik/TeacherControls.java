package com.sztosik;

import javafx.fxml.FXML;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;

public class TeacherControls {
    @FXML
    AnchorPane rightPane;

    @FXML
    HBox filtersPane;

    @FXML
    Pane displayPane;

    @FXML
    void showGrades(){
        System.out.println("Pokazuję oceny nauczyciela");
    }

    @FXML
    void showSchedule(){
        System.out.println("Pokazuję plan nauczyciela");
    }

    @FXML
    void addGrade() {
        System.out.println("Dodaję ocenę jako nauczyciel");
    }

    @FXML
    void editGrade() {
        System.out.println("Edytuję ocenę jako nauczyciel");
    }

}

package com.sztosik;

import javafx.fxml.FXML;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;

public class AdminControls {
    @FXML
    AnchorPane rightPane;

    @FXML
    HBox filtersPane;

    @FXML
    Pane displayPane;

    @FXML
    void showGrades(){
        System.out.println("Pokazuję oceny administratora");
    }

    @FXML
    void showSchedule(){
        System.out.println("Pokazuję plan odministratora");
    }

    @FXML
    void add() {
        System.out.println("Dodaję coś jako administrator");
    }

    @FXML
    void edit() {
        System.out.println("Edytuję coś jako administrator");
    }

    @FXML
    void delete() {
        System.out.println("Usuwam coś jako administrator");
    }

    @FXML
    void createBackup() {
        System.out.println("Tworzę kopię zapasową jako administrator");
    }

    @FXML
    void openBackup() {
        System.out.println("Otwieram kopię zapasową jako administrator");
    }


}

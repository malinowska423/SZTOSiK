package com.sztosik;

import javafx.collections.FXCollections;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

public class LogInControls {
    public static String appMode;

    @FXML
    ComboBox<String> userType;

    @FXML
    TextField user;

    @FXML
    PasswordField password;

    @FXML
    private void logIn(){
//        TODO: implement method by connecting to DB and logging in the user

        switch (userType.getSelectionModel().getSelectedIndex()){
            case 0:
                appMode = "student.fxml";
                break;
            case 1:
                appMode = "teacher.fxml";
                break;
            case 2:
                appMode = "admin.fxml";
                break;
         }
        System.out.println("Użytkownik typu " + userType.getSelectionModel().getSelectedItem() + " loguje się");
        ((Stage) userType.getScene().getWindow()).close();
    }

    public void initialize() {
        userType.setItems(FXCollections.observableArrayList(
                "Uczeń/Opiekun", "Nauczyciel", "Administrator")
        );
        userType.getSelectionModel().selectFirst();
    }
}

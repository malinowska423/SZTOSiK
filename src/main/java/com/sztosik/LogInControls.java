package com.sztosik;

import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.sql.SQLException;

public class LogInControls {
    public static String appMode;

    @FXML
    ComboBox<String> userType;

    @FXML
    TextField user;

    @FXML
    PasswordField password;

    @FXML
    Label errorLabel;

    @FXML
    private void logIn(){
//        TODO: implement method by connecting to DB and logging in the user
        errorLabel.setText("");
        User.getInstance().setLogin(user.getText());
        User.getInstance().setPassword(password.getText());
        switch (userType.getSelectionModel().getSelectedIndex()){
            case 0:
                appMode = "student.fxml";
                User.getInstance().setType(User.Type.STUDENT);
                break;
            case 1:
                appMode = "teacher.fxml";
                User.getInstance().setType(User.Type.TEACHER);
                break;
            case 2:
                appMode = "admin.fxml";
                User.getInstance().setType(User.Type.ADMIN);
                break;
         }
        System.out.println("Użytkownik typu " + userType.getSelectionModel().getSelectedItem() + " loguje się");
        try {
//            DatabaseConnection.connect(User.getInstance().getLogin(), User.getInstance().getPassword());
            DatabaseConnection.connect("amalinowska_sztosik", "spioch2K19$");
            ((Stage) userType.getScene().getWindow()).close();
        } catch (SQLException e) {
            errorLabel.setText("Błędna nazwa użytkownika\n lub hasło");
        }
    }

    public void initialize() {
        userType.setItems(FXCollections.observableArrayList(
                "Uczeń/Opiekun", "Nauczyciel", "Administrator")
        );
        userType.getSelectionModel().selectFirst();
//        user.setText("amalinowska_sztosik");
//        password.setText("spioch2K19$");
        user.setText("05013011243");
        password.setText("fajneHaslo");
    }
}

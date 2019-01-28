package com.sztosik;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

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
        filtersPane.getChildren().removeAll(filtersPane.getChildren());
        filtersPane.getChildren().add(new Label("Semestr: "));
        ComboBox semester = new ComboBox<>(getOptions("grades", ""));
        semester.getSelectionModel().selectFirst();
        filtersPane.getChildren().add(semester);
        semester.setOnAction(actionEvent -> showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString()));
        showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString());
    }

    @FXML
    void showSchedule(){
        System.out.println("Pokazuję plan ucznia");
        filtersPane.getChildren().removeAll(filtersPane.getChildren());
        filtersPane.getChildren().add(new Label("Semestr: "));
        ComboBox semester = new ComboBox<>(getOptions("semester", ""));
        semester.getSelectionModel().selectFirst();
        filtersPane.getChildren().add(semester);

        filtersPane.getChildren().add(new Label("Klasa: "));
        ComboBox schoolClass = new ComboBox<>(getOptions("class", semester.getSelectionModel().getSelectedItem().toString()));
        schoolClass.setOnAction(actionEvent ->
                showScheduleForClass(semester.getSelectionModel().getSelectedItem().toString(),
                        schoolClass.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(schoolClass);

        filtersPane.getChildren().add(new Label("Nauczyciel: "));
        ComboBox teacher = new ComboBox<>(getOptions("teacher", semester.getSelectionModel().getSelectedItem().toString()));
        teacher.setOnAction(actionEvent ->
                showScheduleForTeacher(semester.getSelectionModel().getSelectedItem().toString(),
                        teacher.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(teacher);

        filtersPane.getChildren().add(new Label("Sala: "));
        ComboBox classRoom = new ComboBox<>(getOptions("classroom", semester.getSelectionModel().getSelectedItem().toString()));
        classRoom.setOnAction(actionEvent ->
                showScheduleForClassroom(semester.getSelectionModel().getSelectedItem().toString(),
                        classRoom.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(classRoom);

        semester.setOnAction(actionEvent -> {
            schoolClass.setItems(getOptions("class", semester.getSelectionModel().getSelectedItem().toString()));
            teacher.setItems(getOptions("teacher", semester.getSelectionModel().getSelectedItem().toString()));
            classRoom.setItems(getOptions("classroom", semester.getSelectionModel().getSelectedItem().toString()));
        });

    }

    private ObservableList<String> getOptions(String filterType, String semester) {
//        TODO: implement method where sql queries find options for filters
        List <String> options = new ArrayList<>();
        switch (filterType) {
            case "semester":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT semestr FROM zajecia JOIN " +
                        "klasa_uczniowie on zajecia.id_klasy = klasa_uczniowie.id_klasy " +
                        "WHERE id_ucznia LIKE '" + User.getInstance().getLogin() + "' ORDER BY semestr DESC;")));
                break;
            case "grades":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT semestr FROM oceny " +
                        "WHERE id_ucznia LIKE '" + User.getInstance().getLogin() + "' ORDER BY semestr DESC;")));
                break;
            case "class":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT id_klasy FROM zajecia " +
                        "WHERE semestr LIKE '" + semester + "' ORDER BY id_klasy;")));
                break;
            case "teacher":
                try {
                    options.addAll(FXCollections.observableArrayList(DatabaseConnection.executeQuery(
                            "SELECT imie, nazwisko FROM nauczyciele ORDER BY nazwisko, imie;", 2
                    ).split(";")));
                } catch (SQLException e) {
                    options.add("Brak nauczycieli");
                }
                break;
            case "classroom":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT id_sali FROM zajecia " +
                        "WHERE semestr LIKE '" + semester + "' ORDER BY id_sali;")));
                break;
        }
        return FXCollections.observableArrayList(options);
    }

    private void showGradesForSemester(String semester) {
//        TODO: run query with grades for specific semester
        System.out.println("Pokazuję oceny ucznia w semestrze " + semester);
    }

    private void showScheduleForClass(String semester, String schoolClass) {
//        TODO: run query with schedule for the class in the semester
        System.out.println("Pokazuję plan dla klasy " + schoolClass + " w semestrze " + semester);
    }

    private void showScheduleForTeacher(String semester, String teacher) {
//        TODO: run query with schedule for the teacher in the semester
        System.out.println("Pokazuję plan dla nauczyciela " + teacher + " w semestrze " + semester);
    }

    private void showScheduleForClassroom(String semester, String classroom) {
//        TODO: run query with the schedule for the classroom in the semester
        System.out.println("Pokazuję plan dla pracowni " + classroom + " w semestrze " + semester);
    }

    private String [] queryOptions(String query) {
        StringBuilder results = new StringBuilder();
        try {
            Statement statement = DatabaseConnection.connection.createStatement();
            ResultSet result = statement.executeQuery(query);
            while (result.next()) {
                results.append(result.getString(1)).append(";");
            }
            return results.toString().split(";");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


}

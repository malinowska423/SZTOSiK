package com.sztosik;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;

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
        ComboBox semester = new ComboBox<>(getOptions("grades"));
        semester.getSelectionModel().selectFirst();
        filtersPane.getChildren().add(semester);
        Button confirm = new Button("Confirm");
        semester.setOnAction(actionEvent -> showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(confirm);
        showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString());
    }

    @FXML
    void showSchedule(){
        System.out.println("Pokazuję plan ucznia");
        filtersPane.getChildren().removeAll(filtersPane.getChildren());
        filtersPane.getChildren().add(new Label("Semestr: "));
        ComboBox semester = new ComboBox<>(getOptions("semester"));
        semester.getSelectionModel().selectFirst();
        filtersPane.getChildren().add(semester);

        filtersPane.getChildren().add(new Label("Klasa: "));
        ComboBox schoolClass = new ComboBox<>(getOptions("class"));
        schoolClass.setOnAction(actionEvent -> showScheduleForClass(semester.getSelectionModel().getSelectedItem().toString(), schoolClass.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(schoolClass);

        filtersPane.getChildren().add(new Label("Nauczyciel: "));
        ComboBox teacher = new ComboBox<>(getOptions("teacher"));
        teacher.setOnAction(actionEvent -> showScheduleForTeacher(semester.getSelectionModel().getSelectedItem().toString(), teacher.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(teacher);

        filtersPane.getChildren().add(new Label("Sala: "));
        ComboBox classRoom = new ComboBox<>(getOptions("classroom"));
        classRoom.setOnAction(actionEvent -> showScheduleForClassroom(semester.getSelectionModel().getSelectedItem().toString(), classRoom.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(classRoom);

    }

    private ObservableList<String> getOptions(String filterType) {
//        TODO: implement method where sql queries find options for filters
        List <String> options = new ArrayList<>();
        switch (filterType) {
            case "grades":
                options.addAll(FXCollections.observableArrayList("18/1", "18/2", "17/1"));
                break;
            case "semester":
                options.addAll(FXCollections.observableArrayList("18/1", "18/2", "17/1"));
                break;
            case "class":
                options.addAll(FXCollections.observableArrayList("IA", "3C", "8B"));
                break;
            case "teacher":
                options.addAll(FXCollections.observableArrayList("Nowak", "Kowalczyk", "Wójcik"));
                break;
            case "classroom":
                options.addAll(FXCollections.observableArrayList("18", "21", "5", "7", "12"));
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


}

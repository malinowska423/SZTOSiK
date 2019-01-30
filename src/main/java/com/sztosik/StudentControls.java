package com.sztosik;

import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.layout.*;
import javafx.scene.text.Font;
import javafx.stage.Stage;

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
    Pane schedulePane;

    @FXML
    GridPane grid;

    @FXML
    Pane gradesPane;

    @FXML
    VBox gradesBox;

    public void initialize() {
        schedulePane.setVisible(false);
        gradesBox.setVisible(false);
    }

    @FXML
    void showGrades(){
        schedulePane.setVisible(false);
        gradesPane.setVisible(true);
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
        schedulePane.setVisible(true);
        gradesPane.setVisible(false);
        System.out.println("Pokazuję plan ucznia");
        filtersPane.getChildren().removeAll(filtersPane.getChildren());
        filtersPane.getChildren().add(new Label("Semestr: "));
        ComboBox semester = new ComboBox<>(getOptions("semester", ""));
        semester.getSelectionModel().selectFirst();
        filtersPane.getChildren().add(semester);

        filtersPane.getChildren().add(new Label("Klasa: "));
        ComboBox schoolClass = new ComboBox<>(getOptions("class", semester.getSelectionModel().getSelectedItem().toString()));
        schoolClass.setOnAction(actionEvent -> {
                if(schoolClass.getSelectionModel().getSelectedItem() != null)
                showScheduleForClass(semester.getSelectionModel().getSelectedItem().toString(),
                        schoolClass.getSelectionModel().getSelectedItem().toString());
        });
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

        try {
            String studentClass;
            studentClass = DatabaseConnection.executeQuery("SELECT id_klasy from klasa_uczniowie where id_ucznia = '" + User.getInstance().getLogin() + "'",1);
            studentClass = studentClass.substring(0,4);
            showScheduleForClass(semester.getSelectionModel().getSelectedItem().toString(),studentClass);
        } catch (SQLException e) {
            e.printStackTrace();
        }
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
        grid.getChildren().clear();
        try {
            System.out.println("|" + semester + "|" + User.getInstance().getLogin() + "|");
            Statement statement = DatabaseConnection.connection.createStatement();
            ResultSet result = statement.executeQuery("select wartosc,waga,data,opis,imie,nazwisko,nazwa from oceny " +
                    "join kursy k on oceny.id_kursu = k.id_kursu " +
                    "join przedmioty p on k.id_przedmiotu = p.id_przedmiotu " +
                    "join nauczyciele n on k.id_nauczyciela = n.pesel " +
                    "where id_ucznia = '" + User.getInstance().getLogin() + "'" +
                    "and semestr = '" + semester + "' order by oceny.id_kursu,oceny.data;");
            if(!result.next())
                return;
            String current = "xdxdxd";
            GridPane gradesGrid = new GridPane();
//            gradesGrid.setPrefSize(990,665);
            gradesGrid.setAlignment(Pos.CENTER);
            gradesGrid.setVgap(5);
            gradesGrid.setHgap(10);
            gradesPane.getChildren().add(gradesGrid);

            int row = -1;
            int column = 1;
            System.out.println("ELOO");
            while (result.next())
            {
                if(!result.getString("nazwa").equals(current)) {
                    row++;
                    column = 1;
                    Label label = new Label(result.getString("nazwa"));
                    current = label.getText();
                    label.setStyle("-fx-min-height: 30;-fx-min-width: 150;-fx-alignment: center;-fx-font-size: 20");
                    gradesGrid.add(label, 0, row);
                }
                Label label = new Label(result.getString("wartosc"));
                int waga = result.getInt("waga");
                label.setStyle("-fx-font-size: 17;-fx-min-width: 25;-fx-alignment: center;-fx-background-color: rgba(" + 44*waga +"," + 50+30*waga + "," + 140+10*waga + ",1)");
                gradesGrid.add(label, column,row);
                column++;

                Label description = new Label("waga: " + result.getString("waga") + "\ndata: " + result.getString("data") +
                        "\nwyst. przez: " + result.getString("imie") + " " + result.getString("nazwisko") +
                        "\nopis: " + result.getString("opis"));
                gradesPane.getChildren().add(description);
                description.setVisible(false);
                label.setOnMouseEntered(mouseEvent -> {
                    System.out.println(mouseEvent.getScreenX());
                    description.setStyle("-fx-background-color: rgba(14,255,7,0.95)");
                    description.setLayoutX(mouseEvent.getSceneX()-290);
                    description.setLayoutY(mouseEvent.getSceneY()-55);
                    description.setVisible(true);
                    description.toFront();
                });
                label.setOnMouseExited(mouseEvent -> {
                    description.setVisible(false);
                });
            }
            gradesGrid.toFront();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Pokazuję oceny ucznia w semestrze " + semester);


    }

    private void showScheduleForClass(String semester, String schoolClass) {
//        TODO: run query with schedule for the class in the semester
         grid.getChildren().clear();
        try {
            System.out.println("|" + semester + "|" + schoolClass + "|");
            Statement statement = DatabaseConnection.connection.createStatement();
            ResultSet result = statement.executeQuery("select nr_lekcji, nazwa, id_sali,dzien_tygodnia from zajecia " +
                    "join kursy k on zajecia.id_kursu = k.id_kursu " +
                    "join przedmioty p on k.id_przedmiotu = p.id_przedmiotu " +
                    "where id_klasy = '" + schoolClass + "'" +
                    "and semestr = '" + semester + "' order by dzien_tygodnia,nr_lekcji;");
            while (result.next()){
                int idx=-1;
                switch (result.getString("dzien_tygodnia")) {
                    case "pon":
                        idx = 1;
                        break;
                    case "wt":
                        idx = 2;
                        break;
                    case "śr":
                        idx = 3;
                        break;
                    case "czw":
                        idx = 4;
                        break;
                    case "pt":
                        idx = 5;
                        break;
                }
                Label label = new Label(result.getString("nazwa")+ "  " +result.getString("id_sali"));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-alignment: center;-fx-background-color: rgba(199,199,200,0.5);-fx-font-size: 14");
                grid.add(label, idx,result.getInt("nr_lekcji")-1);
            }
            result = statement.executeQuery("select nr_lekcji,poczatek,koniec from dzwonki where nr_lekcji between 1 and 7");
            while (result.next()) {
                Label label = new Label(result.getString("poczatek").substring(0,5) + "-" + result.getString("koniec").substring(0,5));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-alignment: center;-fx-font-size: 24");
                grid.add(label,0,result.getInt("nr_lekcji")-1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Pokazuję plan dla klasy " + schoolClass + " w semestrze " + semester);
    }

    private void showScheduleForTeacher(String semester, String teacher) {
//        TODO: run query with schedule for the teacher in the semester
        grid.getChildren().clear();
        try {
            System.out.println("|" + semester + "|" + teacher + "|");
            Statement statement = DatabaseConnection.connection.createStatement();
            ResultSet result = statement.executeQuery("select nr_lekcji, nazwa, id_sali,dzien_tygodnia,id_klasy from zajecia " +
                    "join kursy k on zajecia.id_kursu = k.id_kursu " +
                    "join przedmioty p on k.id_przedmiotu = p.id_przedmiotu " +
                    "join nauczyciele n on k.id_nauczyciela = n.pesel " +
                    "where imie = '" + teacher.split(" ")[0] + "' " +
                    "and nazwisko = '" + teacher.split(" ")[1] + "' " +
                    "and semestr = '" + semester + "' order by dzien_tygodnia,nr_lekcji;");
            while (result.next()){
                int idx=-1;
                switch (result.getString("dzien_tygodnia")) {
                    case "pon":
                        idx = 1;
                        break;
                    case "wt":
                        idx = 2;
                        break;
                    case "śr":
                        idx = 3;
                        break;
                    case "czw":
                        idx = 4;
                        break;
                    case "pt":
                        idx = 5;
                        break;
                }
                Label label = new Label(result.getString("nazwa")+ "  " +result.getString("id_sali") + "\nklasa " + result.getString("id_klasy"));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-alignment: center;-fx-background-color: rgba(199,199,200,0.5);-fx-font-size: 14");
                grid.add(label, idx,result.getInt("nr_lekcji")-1);
            }
            result = statement.executeQuery("select nr_lekcji,poczatek,koniec from dzwonki where nr_lekcji between 1 and 7");
            while (result.next()) {
                Label label = new Label(result.getString("poczatek").substring(0,5) + "-" + result.getString("koniec").substring(0,5));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-alignment: center;-fx-font-size: 24");
                grid.add(label,0,result.getInt("nr_lekcji")-1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Pokazuję plan dla nauczyciela " + teacher + " w semestrze " + semester);
    }

    private void showScheduleForClassroom(String semester, String classroom) {
//        TODO: run query with the schedule for the classroom in the semester
        grid.getChildren().clear();
        try {
            System.out.println("|" + semester + "|" + classroom + "|");
            Statement statement = DatabaseConnection.connection.createStatement();
            ResultSet result = statement.executeQuery("select nr_lekcji, nazwa,dzien_tygodnia,id_klasy from zajecia " +
                    "join kursy k on zajecia.id_kursu = k.id_kursu " +
                    "join przedmioty p on k.id_przedmiotu = p.id_przedmiotu " +
                    "join nauczyciele n on k.id_nauczyciela = n.pesel " +
                    "where id_sali = " + classroom + " " +
                    "and semestr = '" + semester + "' order by dzien_tygodnia,nr_lekcji;");
            while (result.next()){
                int idx=-1;
                switch (result.getString("dzien_tygodnia")) {
                    case "pon":
                        idx = 1;
                        break;
                    case "wt":
                        idx = 2;
                        break;
                    case "śr":
                        idx = 3;
                        break;
                    case "czw":
                        idx = 4;
                        break;
                    case "pt":
                        idx = 5;
                        break;
                }
                Label label = new Label(result.getString("nazwa") + "\nklasa " + result.getString("id_klasy"));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-alignment: center;-fx-background-color: rgba(199,199,200,0.5);-fx-font-size: 14");
                grid.add(label, idx,result.getInt("nr_lekcji")-1);
            }
            result = statement.executeQuery("select nr_lekcji,poczatek,koniec from dzwonki where nr_lekcji between 1 and 7");
            while (result.next()) {
                Label label = new Label(result.getString("poczatek").substring(0,5) + "-" + result.getString("koniec").substring(0,5));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-alignment: center;-fx-font-size: 24");
                grid.add(label,0,result.getInt("nr_lekcji")-1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
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

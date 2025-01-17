package com.sztosik;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.control.*;
import javafx.scene.layout.*;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AdminControls {
    @FXML
    AnchorPane rightPane;

    @FXML
    HBox filtersPane;

    @FXML
    Pane gradesPane;

    @FXML
    VBox gradesBox;

    @FXML
    Pane schedulePane;

    @FXML
    GridPane grid;

    @FXML
    BorderPane addPane;

    @FXML
    VBox addList;

    @FXML
    AnchorPane formAddPane;

    @FXML
    AnchorPane addStudentForm;

    @FXML
    TextField formStudentPesel;

    @FXML
    TextField formStudentName;

    @FXML
    TextField formStudentSurname;

    @FXML
    DatePicker formStudentDateOfBirth;

    @FXML
    TextField formStudentAddress;

    @FXML
    TextField formStudentParent1;

    @FXML
    TextField formStudentParent2;



    public void initialize(){

    }

    @FXML
    void showGrades(){
        setAllNotVisible();
        filtersPane.setVisible(true);
        schedulePane.setVisible(false);
        gradesPane.setVisible(true);
        System.out.println("Pokazuję oceny admina");
        filtersPane.getChildren().removeAll(filtersPane.getChildren());
        filtersPane.getChildren().add(new Label("Semestr: "));
        ComboBox semester = new ComboBox<>(getOptions("gradesAdmin", ""));
        semester.getSelectionModel().selectFirst();
        filtersPane.getChildren().add(semester);

        filtersPane.getChildren().add(new Label("Przedmiot: "));
        ComboBox subject = new ComboBox<>(getOptions("subjectAdmin", semester.getSelectionModel().getSelectedItem().toString()));

        filtersPane.getChildren().add(subject);
        subject.getSelectionModel().selectFirst();

        filtersPane.getChildren().add(new Label("Klasa: "));
        ComboBox schoolClass = new ComboBox<>(getOptions("classAdmin", semester.getSelectionModel().getSelectedItem().toString() + ";"
                + subject.getSelectionModel().getSelectedItem().toString()));
        filtersPane.getChildren().add(schoolClass);
        schoolClass.getSelectionModel().selectFirst();


        subject.setOnAction(actionEvent -> {
            if(subject.getSelectionModel().getSelectedItem() != null && semester.getSelectionModel().getSelectedItem() != null && schoolClass.getSelectionModel().getSelectedItem() != null)
                showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString(),
                        subject.getSelectionModel().getSelectedItem().toString(), schoolClass.getSelectionModel().getSelectedItem().toString());
        });

        schoolClass.setOnAction(actionEvent -> {
            if(schoolClass.getSelectionModel().getSelectedItem() != null && semester.getSelectionModel().getSelectedItem() != null && schoolClass.getSelectionModel().getSelectedItem() != null)
                showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString(), subject.getSelectionModel().getSelectedItem().toString(),
                        schoolClass.getSelectionModel().getSelectedItem().toString());
        });

        semester.setOnAction(actionEvent -> {
            subject.setItems(getOptions("subjectAdmin", semester.getSelectionModel().getSelectedItem().toString()));
            subject.getSelectionModel().selectFirst();
            schoolClass.setItems(getOptions("classAdmin", semester.getSelectionModel().getSelectedItem().toString() + ";" + subject.getSelectionModel().getSelectedItem().toString()));
            schoolClass.getSelectionModel().selectFirst();
            showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString(),subject.getSelectionModel().getSelectedItem().toString(),schoolClass.getSelectionModel().getSelectedItem().toString());
        });

        showGradesForSemester(semester.getSelectionModel().getSelectedItem().toString(), subject.getSelectionModel().getSelectedItem().toString(),schoolClass.getSelectionModel().getSelectedItem().toString());
    }

    @FXML
    void showSchedule(){

        setAllNotVisible();
        filtersPane.setVisible(true);
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

    }

    private ObservableList<String> getOptions(String filterType, String semester) {
//        TODO: implement method where sql queries find options for filters
        System.out.println(semester);
        List <String> options = new ArrayList<>();
        switch (filterType) {
            case "semester":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT semestr FROM zajecia JOIN " +
                        "klasa_uczniowie on zajecia.id_klasy = klasa_uczniowie.id_klasy " +
                        "JOIN kursy on zajecia.id_kursu = kursy.id_kursu " +
                        "WHERE id_nauczyciela LIKE '" + User.getInstance().getLogin() + "' ORDER BY semestr DESC;")));
                break;
            case "grades":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT semestr FROM oceny " +
                        "JOIN kursy on oceny.id_kursu = kursy.id_kursu " +
                        "WHERE id_nauczyciela LIKE '" + User.getInstance().getLogin() + "' ORDER BY semestr DESC;")));
                break;
            case "gradesAdmin":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT semestr FROM oceny ORDER BY semestr DESC")));
                break;
            case "class":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT id_klasy FROM zajecia " +
                        "WHERE semestr LIKE '" + semester + "' ORDER BY id_klasy;")));
                break;
            case "classTeacher":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT id_klasy FROM zajecia " +
                        "JOIN kursy on zajecia.id_kursu = kursy.id_kursu " +
                        "JOIN przedmioty on kursy.id_przedmiotu = przedmioty.id_przedmiotu " +
                        "WHERE semestr LIKE '" + semester.split(";")[0] + "' " +
                        "AND id_nauczyciela LIKE '" + User.getInstance().getLogin() + "' " +
                        "AND nazwa LIKE '" + semester.split(";")[1] + "' ORDER BY id_klasy;")));
                break;
            case "classAdmin":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT id_klasy FROM zajecia " +
                        "JOIN kursy on zajecia.id_kursu = kursy.id_kursu " +
                        "JOIN przedmioty on kursy.id_przedmiotu = przedmioty.id_przedmiotu " +
                        "WHERE semestr LIKE '" + semester.split(";")[0] + "' " +
                        "AND nazwa LIKE '" + semester.split(";")[1] + "' ORDER BY id_klasy;")));
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
            case "subject":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT nazwa FROM zajecia " +
                        "JOIN kursy on kursy.id_kursu = zajecia.id_kursu " +
                        "JOIN nauczyciele on kursy.id_nauczyciela = nauczyciele.pesel " +
                        "JOIN przedmioty on kursy.id_przedmiotu = przedmioty.id_przedmiotu " +
                        "WHERE id_nauczyciela LIKE '" + User.getInstance().getLogin() + "' " +
                        "AND semestr LIKE '" + semester + "'" )));
                break;
            case "subjectAdmin":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT nazwa FROM zajecia " +
                        "JOIN kursy on kursy.id_kursu = zajecia.id_kursu " +
                        "JOIN nauczyciele on kursy.id_nauczyciela = nauczyciele.pesel " +
                        "JOIN przedmioty on kursy.id_przedmiotu = przedmioty.id_przedmiotu " +
                        "WHERE semestr LIKE '" + semester + "'" )));
                break;
            case "subjectClass":
                options.addAll(FXCollections.observableArrayList(queryOptions("SELECT DISTINCT nazwa FROM zajecia " +
                        "JOIN kursy on kursy.id_kursu = zajecia.id_kursu " +
                        "JOIN przedmioty on kursy.id_przedmiotu = przedmioty.id_przedmiotu " +
                        "WHERE id_klasy LIKE '" + semester.split(";")[1] + "' " +
                        "AND semestr LIKE '" + semester.split(";")[0] + "'" )));
        }
        return FXCollections.observableArrayList(options);
    }

    private void showGradesForSemester(String semester,String subject,String schoolClass) {

//        TODO: run query with grades for specific semester
        gradesPane.getChildren().clear();
        try {
            gradesPane.setVisible(true);
            gradesPane.getChildren().addAll(new Label("SDFDSFDSF"));
            System.out.println("|" + semester + "|" + User.getInstance().getLogin() + "|" + schoolClass + "|");
            Statement statement = DatabaseConnection.connection.createStatement();
            ResultSet result = statement.executeQuery("select oceny.id_ucznia,wartosc,waga,data,opis,imie,nazwisko,nazwa from oceny " +
                    "join kursy k on oceny.id_kursu = k.id_kursu " +
                    "join przedmioty p on k.id_przedmiotu = p.id_przedmiotu " +
                    "join klasa_uczniowie ku on oceny.id_ucznia = ku.id_ucznia " +
                    "join uczniowie u on ku.id_ucznia = u.pesel " +
                    "and id_klasy = '" + schoolClass + "' " +
                    "and semestr = '" + semester + "' " +
                    "and nazwa = '" + subject + "' order by ku.id_ucznia,oceny.data;");
            if(!result.next())
                return;
            String current = "xdxdxd";
            GridPane gradesGrid = new GridPane();
            gradesGrid.setVisible(true);
//            gradesGrid.setPrefSize(990,665);
            gradesGrid.setAlignment(Pos.CENTER);
            gradesGrid.setVgap(5);
            gradesGrid.setHgap(10);
            gradesPane.getChildren().add(gradesGrid);
            gradesGrid.setAlignment(Pos.CENTER);

            int row = -1;
            int column = 1;
            System.out.println("ELOO");
            while (result.next())
            {
                if(!result.getString("id_ucznia").equals(current)) {
                    current = result.getString("id_ucznia");
                    row++;
                    column = 1;
                    Label label = new Label(result.getString("imie") + " " + result.getString("nazwisko"));
                    label.setStyle("-fx-min-height: 20;-fx-min-width: 150;-fx-alignment: center;-fx-font-size: 15");
                    gradesGrid.add(label, 0, row);
                }
                Label label = new Label(result.getString("wartosc"));
                int waga = result.getInt("waga");
                label.setStyle("-fx-font-size: 13;-fx-min-width: 25;-fx-alignment: center;-fx-background-color: rgba(" + (255-44*waga) +"," + 50+30*waga + "," + 140+10*waga + ",1)");
                if(result.getString("opis").equals("ocena rocz") || result.getString("opis").equals("ocena sem")){
                    label.setStyle("-fx-font-size: 13;-fx-min-width: 25;-fx-alignment: center;-fx-background-color: orange");
                }
                gradesGrid.add(label, column,row);
                column++;

                Label description = new Label("waga: " + result.getString("waga") + "\ndata: " + result.getString("data") +
                        "\nopis: " + result.getString("opis"));
                gradesPane.getChildren().add(description);
                description.setVisible(false);
                description.setStyle("-fx-font-size: 12;-fx-min-width:200;-fx-min-height: 100;-fx-alignment: center;-fx-background-color: rgba(14,255,7,0.95)");
                label.setOnMouseEntered(mouseEvent -> {
                    description.setLayoutX(mouseEvent.getSceneX()-290);
                    description.setLayoutY(mouseEvent.getSceneY()-55);
                    description.setVisible(true);
                    description.toFront();
                });
                label.setOnMouseExited(mouseEvent -> {
                    description.setVisible(false);
                });
            }

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
            ResultSet result = statement.executeQuery("select nr_lekcji, nazwa, id_sali,dzien_tygodnia,imie,nazwisko from zajecia " +
                    "join kursy k on zajecia.id_kursu = k.id_kursu " +
                    "join przedmioty p on k.id_przedmiotu = p.id_przedmiotu " +
                    "join nauczyciele n on k.id_nauczyciela = n.pesel " +
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
                Label label = new Label(result.getString("nazwa")+ "  " +result.getString("id_sali") + "\n" + result.getString("imie").charAt(0) + "" + result.getString("nazwisko").charAt(0));
                label.setStyle("-fx-min-height: 85;-fx-min-width: 165;-fx-text-alignment: center;-fx-alignment: center;-fx-background-color: rgba(199,199,200,0.5);-fx-font-size: 14");
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
            ResultSet result = statement.executeQuery("select nr_lekcji, nazwa,dzien_tygodnia,id_klasy,imie,nazwisko from zajecia " +
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
                Label label = new Label(result.getString("nazwa") + "\n" + result.getString("imie").charAt(0) + "" + result.getString("nazwisko").charAt(0) +" klasa " + result.getString("id_klasy"));
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


    @FXML
    void add() {
        System.out.println("Dodaję coś jako administrator");
        setAllNotVisible();
        setAllFormsNotVisible();
        addPane.setVisible(true);
        addList.setVisible(true);
        formAddPane.setVisible(true);
        addList.getChildren().removeAll(addList.getChildren());
        //student
        Button student = new Button("Ucznia");
        student.setPrefWidth(addList.getPrefWidth());
        student.setOnAction(actionEvent -> showAddStudentForm());
        addList.getChildren().add(student);
        
        //bell
        Button bell = new Button("Lekcję");
        bell.setPrefWidth(addList.getPrefWidth());
        bell.setOnAction(actionEvent -> showAddBellForm());
        addList.getChildren().add(bell);
        
        //class
        Button schoolClass = new Button("Klasę");
        schoolClass.setPrefWidth(addList.getPrefWidth());
        schoolClass.setOnAction(actionEvent -> showAddClassForm());
        addList.getChildren().add(schoolClass);
        
        //course
        Button course = new Button("Kurs");
        course.setPrefWidth(addList.getPrefWidth());
        course.setOnAction(actionEvent -> showAddCourseForm());
        addList.getChildren().add(course);
        
        //teacher
        Button teacher = new Button("Nauczyciela");
        teacher.setPrefWidth(addList.getPrefWidth());
        teacher.setOnAction(actionEvent -> showAddTeacherForm());
        addList.getChildren().add(teacher);
        
        //grade
        Button grade = new Button("Ocenę");
        grade.setPrefWidth(addList.getPrefWidth());
        grade.setOnAction(actionEvent -> showAddGradeForm());
        addList.getChildren().add(grade);
        
        //subject
        Button subject = new Button("Przedmiot");
        subject.setPrefWidth(addList.getPrefWidth());
        subject.setOnAction(actionEvent -> showAddSubjectForm());
        addList.getChildren().add(subject);
        
        //classroom
        Button classroom = new Button("Salę");
        classroom.setPrefWidth(addList.getPrefWidth());
        classroom.setOnAction(actionEvent -> showAddClassRoomForm());
        addList.getChildren().add(classroom);
        
        //schedule
        Button schedule = new Button("Zajęcia");
        schedule.setPrefWidth(addList.getPrefWidth());
        schedule.setOnAction(actionEvent -> showAddScheduleForm());
        addList.getChildren().add(schedule);
    }

    private void showAddClassForm() {
        System.out.println("Pokazuję formularz dodawania klasy");
        setAllFormsNotVisible();
    }

    private void showAddCourseForm() {
        System.out.println("Pokazuję formularz dodawania kursu");
        setAllFormsNotVisible();
    }

    private void showAddTeacherForm() {
        System.out.println("Pokazuję formularz dodawania nauczyciela");
        setAllFormsNotVisible();
    }

    private void showAddGradeForm() {
        System.out.println("Pokazuję formularz dodawania oceny");
        setAllFormsNotVisible();
    }

    private void showAddSubjectForm() {
        System.out.println("Pokazuję formularz dodawania przedmiotu");
        setAllFormsNotVisible();
    }

    private void showAddClassRoomForm() {
        System.out.println("Pokazuję formularz dodawania sali lekcyjnej");
        setAllFormsNotVisible();
    }

    private void showAddScheduleForm() {
        System.out.println("Pokazuję formularz dodawania zajęć");
        setAllFormsNotVisible();
    }

    private void showAddBellForm() {
        System.out.println("Pokazuję formularz dodawania lekcji");
        setAllFormsNotVisible();
    }

    private void showAddStudentForm() {
        System.out.println("Pokazuję formularz dodawania ucznia");
        setAllFormsNotVisible();
        addStudentForm.setVisible(true);
    }

    @FXML
    void addStudent() {
        System.out.println("Dodaję ucznia");
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
    AnchorPane createBackupPane;

    @FXML
    TextField backupPath;

    @FXML
    Label errorBackup;

    @FXML
    void createBackup() {
        System.out.println("Tworzę kopię zapasową jako administrator");
        setAllNotVisible();
        createBackupPane.setVisible(true);
        backupPath.setText("C:\\Program Files\\MariaDB 10.3\\bin\\mysqldump.exe");
    }

    @FXML
    void createBackupFile() {
        errorBackup.setVisible(false);
        if (!backupPath.getText().isEmpty()) {

            try {
                System.out.println("Tworzę plik kopii zapasowej");
                Runtime rt = Runtime.getRuntime();
//                Process p = rt.exec("mysqldump -utodo_user -ptoto_passowrd --database mydb_name");
                Process p = rt.exec(new String[]{"cmd.exe", "/c", "\"" + backupPath.getText() +
                        "\" -h sql.amalinowska.nazwa.pl -u amalinowska_sztosik --password=\"spioch2K19$\" --routines amalinowska_sztosik > "
                        + "src\\main\\resources\\sql\\backup.sql" });
//                InputStream is=p.getInputStream();
//                FileOutputStream fos = new FileOutputStream("tekst.txt");
//                int ch;
//                while((ch=is.read())!=-1) {
//                    fos.write(ch);
//                }
//                fos.close();
//                is.close();
                p.waitFor();
                System.out.println("Utworzono");
                errorBackup.setText("Utworzono backup");
            } catch (IOException e) {
                errorBackup.setVisible(true);
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        } else {
            errorBackup.setVisible(true);
        }
    }

    @FXML
    AnchorPane openBackupPane;

    @FXML
    TextField backupFilePath;

    @FXML
    Label errorBackup1;

    @FXML
    void openBackup() {
        System.out.println("Otwieram kopię zapasową jako administrator");
        setAllNotVisible();
        openBackupPane.setVisible(true);
        backupFilePath.setText("src\\main\\resources\\sql\\backup.sql");
    }

    @FXML
    void openBackupFile() {
        errorBackup1.setVisible(false);
        if (!backupFilePath.getText().isEmpty()) {

            try {
                System.out.println("Otwieram plik kopii zapasowej");
                Statement stm = DatabaseConnection.connection.createStatement();
                Runtime rt = Runtime.getRuntime();
//                Process p = rt.exec("mysqldump -utodo_user -ptoto_passowrd --database mydb_name");
                String mysql = "C:\\Program Files\\MariaDB 10.3\\bin\\mysql.exe";
                Process p = rt.exec(new String[]{"cmd.exe", "/c", "\"" + mysql +
                        "\" -h sql.amalinowska.nazwa.pl -u amalinowska_sztosik --password=\"spioch2K19$\" amalinowska_sztosik < " +
                backupFilePath.getText()});
                p.waitFor();
                System.out.println("Załadowano");
                errorBackup.setText("Załadowano backup");
            } catch (IOException e) {
                errorBackup.setVisible(true);
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (SQLException e) {
                e.printStackTrace();
            }

        } else {
            errorBackup1.setVisible(true);
        }
    }

    private void setAllNotVisible() {
        filtersPane.setVisible(false);
        gradesPane.setVisible(false);
        schedulePane.setVisible(false);
        addPane.setVisible(false);
        formAddPane.setVisible(false);
        addList.setVisible(false);
        createBackupPane.setVisible(false);
        openBackupPane.setVisible(false);
    }

    private void setAllFormsNotVisible() {
        addStudentForm.setVisible(false);
    }


}

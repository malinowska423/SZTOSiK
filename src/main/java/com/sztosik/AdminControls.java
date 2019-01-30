package com.sztosik;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.DatePicker;
import javafx.scene.control.TextField;
import javafx.scene.layout.*;

public class AdminControls {
    @FXML
    AnchorPane rightPane;

    @FXML
    HBox filtersPane;

    @FXML
    Pane gradesPane;

    @FXML
    Pane schedulePane;

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
        System.out.println("Pokazuję oceny administratora");
        setAllNotVisible();
        filtersPane.setVisible(true);
        gradesPane.setVisible(true);
    }

    @FXML
    void showSchedule(){
        System.out.println("Pokazuję plan administratora");
        setAllNotVisible();
        filtersPane.setVisible(true);
        schedulePane.setVisible(true);
    }

    @FXML
    void add() {
        System.out.println("Dodaję coś jako administrator");
        setAllNotVisible();
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
    }

    private void showAddCourseForm() {
        System.out.println("Pokazuję formularz dodawania kursu");
    }

    private void showAddTeacherForm() {
        System.out.println("Pokazuję formularz dodawania nauczyciela");
    }

    private void showAddGradeForm() {
        System.out.println("Pokazuję formularz dodawania oceny");
    }

    private void showAddSubjectForm() {
        System.out.println("Pokazuję formularz dodawania przedmiotu");
    }

    private void showAddClassRoomForm() {
        System.out.println("Pokazuję formularz dodawania sali lekcyjnej");
    }

    private void showAddScheduleForm() {
        System.out.println("Pokazuję formularz dodawania zajęć");
    }

    private void showAddBellForm() {
        System.out.println("Pokazuję formularz dodawania lekcji");
    }

    private void showAddStudentForm() {
        System.out.println("Pokazuję formularz dodawania ucznia");
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
    void createBackup() {
        System.out.println("Tworzę kopię zapasową jako administrator");
    }

    @FXML
    void openBackup() {
        System.out.println("Otwieram kopię zapasową jako administrator");
    }

    private void setAllNotVisible() {
        filtersPane.setVisible(false);
        gradesPane.setVisible(false);
        schedulePane.setVisible(false);
        addPane.setVisible(false);
        formAddPane.setVisible(false);
        addList.setVisible(false);
        addStudentForm.setVisible(false);
    }


}

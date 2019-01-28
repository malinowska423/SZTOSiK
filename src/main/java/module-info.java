module SZTOSiK {
    requires javafx.fxml;
    requires javafx.controls;
    requires java.sql;
    opens com.sztosik to javafx.graphics, javafx.fxml;
}
package com.sztosik;

import java.sql.*;

public class Interface {
    public static void main(String[] args) {

        try {
            Connection connection = DriverManager.getConnection("jdbc:mariadb://sql.amalinowska.nazwa.pl:3306/amalinowska_sztosik","amalinowska_sztosik","spioch2K19$");
            Statement statement = connection.createStatement();
            ResultSet result = statement.executeQuery("SELECT * FROM uczniowie LIMIT 1");
            while (result.next()) {
                for (int i=1; i<7; i++){
                    System.out.print(result.getString(i) + " ");
                }
                System.out.println();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

//        GUI.main(null);
    }
}

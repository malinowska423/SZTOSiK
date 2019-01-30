package com.sztosik;

import java.sql.*;
import java.util.ArrayList;

public class Interface {
    private static Statement stmt;


    public static void main(String[] args) {

//        try {
//            Connection connection = DriverManager.getConnection("jdbc:mariadb://sql.amalinowska.nazwa.pl:3306/amalinowska_sztosik","amalinowska_sztosik","spioch2K19$");
//            stmt = connection.createStatement();
//            ResultSet result = stmt.executeQuery("SELECT * FROM uczniowie");
//            while (result.next()) {
//                for (int i=1; i<7; i++){
//                    System.out.print(result.getString(i) + " ");
//                }
//                System.out.println();
//            }
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }


//        GUI.main(null);
    }

    private  void show() {

    }

    public static ArrayList<String[]> getLessons(){
        ArrayList<String[]> list = new ArrayList<>();


        return null;
    }
}

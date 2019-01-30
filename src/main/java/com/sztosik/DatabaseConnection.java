package com.sztosik;

import java.sql.*;

public class DatabaseConnection {
    static Connection connection;

    public static void connect(String user, String password) throws SQLException{
        System.out.println("Użytkownik " + user + " loguje się hasłem " + password);
        connection = DriverManager
                .getConnection("jdbc:mariadb://sql.amalinowska.nazwa.pl:3306/amalinowska_sztosik",
                        user,password);
    }


    public static String executeQuery(String query, int columns) throws SQLException{
        Statement statement = connection.createStatement();
        ResultSet result = statement.executeQuery(query);
        StringBuilder results = new StringBuilder();
        while (result.next()) {
            for (int i = 1; i <= columns; i++) {
                results.append(result.getString(i)).append(" ");
            }
            results.append(";");
        }
//        System.out.println(results.toString());
        return results.toString();
    }

}

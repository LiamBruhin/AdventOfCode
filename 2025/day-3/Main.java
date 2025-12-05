import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.File;

public class Main{
    public static void main(String []args) {
        File input = new File("input.txt");

        int result = 0;
        try(Scanner scanner = new Scanner(input)) {
            while(scanner.hasNextLine()) {
                String data = scanner.nextLine();
                char[] chars = data.toCharArray();
                result += solve(chars);
            }
        } catch(FileNotFoundException e) {
            System.out.println("File Not Found");
            e.printStackTrace();
        }

        System.out.println(result);
    }

    public static int solve(char[] chars) {
        int max = 0;
        for(int i = 0; i < chars.length; i++) {
            for(int j = i + 1; j < chars.length; j++) {
                int joltage = Integer.parseInt("" + chars[i] + chars[j]);
                if(joltage > max) {
                    max = joltage;
                }
            }
        }
        return max;
    }

    public static int solve2(char[] chars) {
        return 0;
    }
}


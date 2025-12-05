import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.File;
import java.util.ArrayList;

public class Main{
    public static void main(String []args) {
        File input = new File("test.txt");

        long result = 0;
        try(Scanner scanner = new Scanner(input)) {
            String data = scanner.nextLine();
            String[] ranges = data.split(",");
            for(String range : ranges) {
                //System.out.println(range);
                int dashIdx = range.indexOf('-');
                String start = range.substring(0, dashIdx);
                String end = range.substring(dashIdx + 1);
                //System.out.println(start + " " + end);

                long startVal = Long.parseLong(start);
                long endVal = Long.parseLong(end);

                for(long i = startVal; i <= endVal; i++) {
                    if(testNum2(i)) {
                        result += i;
                    }
                }
            }
        } catch(FileNotFoundException e) {
            System.out.println("File Not Found");
            e.printStackTrace();
        }

        System.out.println(result);
    }

    public static boolean testNum(long num) {
        String foo = String.valueOf(num);

        if((foo.length() % 2) != 0) return false;

        int center = foo.length() / 2;

        for(int i = 0; i < center; i++){
            if(foo.charAt(i) != foo.charAt(center + i)) {
                return false;
            }
            
        }

        return true;
    }

    public static boolean testNum2(long num) {
        String foo = String.valueOf(num);

        for(int repeats = 2; repeats < foo.length(); repeats++) {
            int jmp = foo.length() / repeats;

            if(repeats % 2 != foo.length() % 2) continue;

            boolean match = true;
            for(int i = 0; i < jmp; i++) {
                char c = foo.charAt(i);
                for(int j = 1; j < repeats - 1; j++) {
                    if(c != foo.charAt((jmp*j) + i)) {
                        match = false;
                    }
                }
            }
            if(match) {
                System.out.println(foo);
                return true;
            }
        }

        return false;
    }
}



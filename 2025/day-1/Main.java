import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.File;

public class Main{
    public static void main(String []args) {
        File input = new File("input.txt");

        Dial d = new Dial();

        int result = 0;
        try(Scanner scanner = new Scanner(input)) {
            while(scanner.hasNextLine()) {
                String data = scanner.nextLine();
                String num = data.substring(1);
                int value = Integer.parseInt(num);
                switch(data.charAt(0)) {
                    case 'L':
                        result += d.turn2(value, true);
                        break;
                    case 'R':
                        result += d.turn2(value, false);
                        break;
                }
                System.out.println(data);
            }
        } catch(FileNotFoundException e) {
            System.out.println("File Not Found");
            e.printStackTrace();
        }

        System.out.println(result);


    }
}

class Dial {
    public int val;

    public Dial() {
        val = 50;
    }

    public int turn1(int distance) {
        val += distance; 
        val %= 100; 
        System.out.println("Val: " + val);
        return val == 0 ? 1 : 0;
    }

    public int turn2(int distance, boolean left) {
        int ret = 0;
        int inc = left ? -1 : 1;
        for(int i = 0; i < distance; i++) {
            val += inc;
            if(val == -1) val = 99;
            if(val == 100) val = 0;
            if(val == 0) ret++;
        }
        return ret;
    }
}


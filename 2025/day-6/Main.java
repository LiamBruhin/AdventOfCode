import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.File;

public class Main{
    public static void main(String []args) {
        File input = new File("input.txt");

        ArrayList<String[]> rows = new ArrayList<>();

        try(Scanner scanner = new Scanner(input)) {
            while(scanner.hasNextLine()) {
                String data = scanner.nextLine();
                String compressed = data.trim().replaceAll("\s+", " ");
                String split[] = compressed.split(" ");
                rows.add(split);
                //System.out.println(Arrays.toString(split));
                System.out.println(data);
            }

            System.out.println(rows.size());

            ArrayList<Equation> eqs = new ArrayList<>();

            String[] top = rows.getFirst();
            for(int i = 0; i < top.length; i++) {
                long nums[] = new long[rows.size() - 1];
                for(int j = 0; j < rows.size() - 1; j++) {
                    nums[j] = Long.parseLong(rows.get(j)[i]);
                }
                Equation newEq = new Equation(rows.getLast()[i].charAt(0), nums);
                System.out.println(newEq);
                eqs.add(newEq);
            }

            long total = 0;

            for(Equation e : eqs) {
                total += e.evaluate();
            }
            System.out.println(total);

        } catch(FileNotFoundException e) {
            System.out.println("File Not Found");
            e.printStackTrace();
        }
    }
}

class Equation {
    char operator;
    long nums[];

    public Equation(char operator, long nums[]) {
        this.operator = operator;
        this.nums = nums;
    }

    public String toString() {
        String s = "";
        for(long n : nums) {
            s += n + " " + operator + " ";
        }
        return s;
    }


    public long evaluate() {
        switch (operator) {
            case '+':
                long sum = 0;
                for(long num : nums) {
                    sum += num;
                }
                return sum;

            case '*':
                long product = nums[0];
                nums[0] = 1;
                for(long num : nums) {
                    product *= num;
                }
                return product;

            default:
                return 0;
        }
    }


}

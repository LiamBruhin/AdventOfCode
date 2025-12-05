/*
 * Decompiled with CFR 0.152.
 */
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Scanner;

public class Main {
    public static void main(String[] stringArray) {
        File file = new File("input.txt");
        int n = 0;
        try (Scanner scanner = new Scanner(file);){
            while (scanner.hasNextLine()) {
                ++n;
                scanner.nextLine();
            }
        }
        catch (FileNotFoundException fileNotFoundException) {
            System.out.println("File Not Found");
            fileNotFoundException.printStackTrace();
        }
        int n2 = 0;
        try (Scanner scanner = new Scanner(file);){
            Object object;
            char[][] cArrayArray = new char[n][];
            int n3 = 0;
            while (scanner.hasNextLine()) {
                String string = scanner.nextLine();
                object = string.toCharArray();
                cArrayArray[n3++] = object;
            }
            System.out.println(Arrays.deepToString((Object[])cArrayArray));
            boolean bl = true;
            while (bl) {
                bl = false;
                object = new ArrayList();
                for (int i = 0; i < cArrayArray.length; ++i) {
                    for (int j = 0; j < cArrayArray[0].length; ++j) {
                        if (cArrayArray[i][j] != '@') continue;
                        int[] nArray = new int[]{i - 1, j - 1};
                        int[] nArray2 = new int[]{i - 1, j};
                        int[] nArray3 = new int[]{i - 1, j + 1};
                        int[] nArray4 = new int[]{i, j + 1};
                        int[] nArray5 = new int[]{i + 1, j + 1};
                        int[] nArray6 = new int[]{i + 1, j};
                        int[] nArray7 = new int[]{i + 1, j - 1};
                        int[] nArray8 = new int[]{i, j - 1};
                        int[][] nArrayArray = new int[][]{nArray, nArray2, nArray3, nArray4, nArray5, nArray6, nArray7, nArray8};
                        int n4 = 0;
                        for (int[] nArray9 : nArrayArray) {
                            if (!Main.inBounds(nArray9, cArrayArray) || cArrayArray[nArray9[0]][nArray9[1]] != '@') continue;
                            ++n4;
                        }
                        if (n4 >= 4) continue;
                        ((ArrayList)object).add(new int[]{i, j});
                        ++n2;
                    }
                }
                Iterator iterator = ((ArrayList)object).iterator();
                while (iterator.hasNext()) {
                    int[] nArray = (int[])iterator.next();
                    cArrayArray[nArray[0]][nArray[1]] = 46;
                    bl = true;
                }
            }
        }
        catch (FileNotFoundException fileNotFoundException) {
            System.out.println("File Not Found");
            fileNotFoundException.printStackTrace();
        }
        System.out.println(n2);
    }

    public static boolean inBounds(int[] nArray, char[][] cArray) {
        return nArray[0] >= 0 && nArray[0] < cArray.length && nArray[1] >= 0 && nArray[1] < cArray[0].length;
    }
}

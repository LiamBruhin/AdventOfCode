import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;

public class Main{
    public static void main(String []args) {
        File input = new File("input.txt");

        HashSet<Range> unique = new HashSet<>();

        ArrayList<Range> ranges = new ArrayList<>();

        int result = 0;
        try(Scanner scanner = new Scanner(input)) {
            while(scanner.hasNextLine()) {
                String data = scanner.nextLine();
                if(data.equals("")) break;
                String[] split = data.split("-");

                Range r = new Range(Long.parseLong(split[0]), Long.parseLong(split[1]));
                if(!unique.contains(r)) {
                    ranges.add(r);
                    unique.add(r);
                    System.out.println(ranges.getLast() + " : " + ranges.getLast().getSize());
                }
            }

            /*
            while(scanner.hasNextLine()) {
                String data = scanner.nextLine();

                long num = Long.parseLong(data);

                System.out.println(num);

                for(Range r : ranges) {
                    if(r.contains(num)) {
                        result++;
                        break;
                    }
                }
            }
            */
            /*
            ArrayList<Range> toRemove = new ArrayList<>();

            for(int i = 0; i < ranges.size(); i++) {
                for(int j = i + 1; j < ranges.size(); j++) {
                    if(ranges.get(i).contains(ranges.get(j))) {
                        System.out.println(ranges.get(i) + " contains " + ranges.get(j));
                        toRemove.add(ranges.get(j));
                    }
                    if(ranges.get(j).contains(ranges.get(i))) {
                        System.out.println(ranges.get(j) + " contains " + ranges.get(i));
                        toRemove.add(ranges.get(i));
                    }
                }
            }

            for(Range r : toRemove) {
                ranges.remove(r);
            }

            long size = 0;
            long intersect = 0;
            for(int i = 0; i < ranges.size(); i++) {
                size += ranges.get(i).getSize();
                System.out.println(ranges.get(i) + " " + ranges.get(i).getSize());
                for(int j = i + 1; j < ranges.size(); j++) {
                    long intersection = ranges.get(i).findIntersection(ranges.get(j));
                    System.out.println(ranges.get(i) + " ∩ " + ranges.get(j) + " : " + intersection);
                    intersect += intersection;
                }
            }

            System.out.println(size);
            System.out.println(intersect);
            System.out.println(size - intersect);
            */


            boolean merged = true;
            while(merged) {
                Iterator<Range> it = unique.stream().sorted().iterator();
                merged = false;
                if(it.hasNext()) {
                    Range prev =  it.next();

                    while(it.hasNext()) {
                        Range curr = it.next();

                        if(prev.intersects(curr)) {
                            merged = true;
                            Range newRange = prev.merge(curr);
                            unique.remove(prev);
                            unique.remove(curr);
                            unique.add(newRange);
                        }

                        prev = curr;
                    }
                }
            }

            long count = 0;
            for(Range r : unique) {
                count += r.getSize();
            }
            System.out.println(count);

        } catch(FileNotFoundException e) {
            System.out.println("File Not Found");
            e.printStackTrace();
        }
    }
}

class Range implements Comparable<Range> {
    private long low;
    private long high;

    public Range merge(Range other) {
        if(intersects(other)) {
            if(contains(other)) return this;
            return new Range(Math.min(low, other.getLow()), Math.max(high, other.getHigh()));
        } else {
            return null;
        }
    }

    public int compareTo(Range other) {
        if(low == other.getLow()) {
            return 0;
        } else {
            return (low - other.getLow()) < 0 ? -1 : 1;
        }
    }

    public long getLow() {
        return low;
    }

    public long getHigh() {
        return high;
    }

    public long getSize() {
        return high - low + 1;
    }

    public String toString() {
        return low + "-" + high;

    }

    public Range(long low, long high) {
        this.low = low;
        this.high = high;
    }

    public boolean contains(long num) {
        return num >= low && num <= high;
    }

    public boolean contains(Range other) {
        return contains(other.getLow()) && contains(other.getHigh());
    }

    public boolean equals(Object o) {
        if(!(o instanceof Range)) return false;
        Range other = (Range)o;

        return low == other.getLow() && high == other.getHigh();
    }

    public int hashCode(){
        return (int)(low + high) * 31;
    }

    // intersect
    // a        b
    // [     c  ]     d
    //       [        ]
    //
    // intersection [max(a, c), min(b,d)]
    //
    // dont intersect
    // a       b
    // [       ]  c        d
    //            [        ]
    //      [       ]
    // fully contained
    // a  c      d   b
    // [  [      ]   ]


    // 12    18
    //    16     20
    //
    //
    //  A) 3-5 -> 5 - 3 + 1 = 3
    //  B) 10-14 -> 14 - 10 + 1 = 5
    //  C) 16-20 -> 20 - 16 + 1 = 5
    //  D) 12-18 -> 18 - 12 + 1 = 7
    //  3 + 5 + 5 + 7 = 20
    //
    //  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
    //      a   A         b           B     c           C
    //                          d                 D
    public boolean intersects(Range other) {
        return Math.max(low, other.low) <= Math.min(high, other.high);
    }

    public long findIntersection(Range other) {
        if(Math.max(low, other.low) <= Math.min(high, other.high)) {
            Range i = new Range(Math.max(low, other.low), Math.min(high, other.high));
            return i.getSize();
        }
        else return 0;
    }
}

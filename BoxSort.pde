class BoxSort implements Comparator {
  public int compare(Object o1, Object o2) {
    if (o1 instanceof PVector && o2 instanceof PVector) {
      PVector p1 = (PVector) o1;
      PVector p2 = (PVector) o2;
      return (int) (p1.x+p1.y+p1.z-(p2.x+p2.y+p2.z));
    }
    return 0;
  }
}

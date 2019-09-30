class BoxRecord {
  PVector pos;
  boolean remove;
  public BoxRecord(PVector pos, boolean remove) {
    this.pos = pos;
    this.remove = remove;
  }
  
  public boolean isRemoval() { return remove; }
  public PVector getPosition() { return pos; }
  
  public boolean equals(Object o) { 
    if (o instanceof BoxRecord) {
      BoxRecord br = (BoxRecord) o;
      return pos.equals(br.getPosition());
    }
    return false;
  }
  
  public int hashCode() {
    return java.util.Objects.hashCode(pos);
  }
}

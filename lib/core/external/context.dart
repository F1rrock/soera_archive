abstract class Context<Type> {
  void goTo(final Type resource);
  Type get content;
  Context<Type> clone();
}
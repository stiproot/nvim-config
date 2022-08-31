
public interface IFactory<T> where T: new()
{
  T Create();
}

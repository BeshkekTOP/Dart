namespace practika2.cSharp
{
    internal class Program
    {
        static void Main()
        {

            Actions();
        }
        static void GuessNum()
        {
            Console.Title = "Угадай число";
            Random rand = new Random();
            int myNum;
            int num = rand.Next(0, 100) + 1;
            Console.WriteLine("Отгадайте число от 1 до 100");
            while (true)
            {
                myNum = int.Parse(Console.ReadLine());
                if (myNum == num)
                {
                    Console.WriteLine("Угадали.");
                    break;
                }
                else

                {
                    if (myNum > num)
                    {
                        Console.WriteLine("Меньше");
                    }
                    else
                    {
                        Console.WriteLine("Больше");
                    }

                }
            }

            Console.ReadKey();
        }

        static void MultiTab()
        {
            for (int i = 1; i <= 10; i++)
            {
                for (int j = 1; j <= 10; j++)
                {
                    Console.Write((i * j).ToString() + "\t");
                }
                Console.WriteLine();
            }
        }
        static void Delitel()
        {
            int num = Convert.ToInt32(Console.ReadLine());
            int num2 = 0;
            while (num2 <= num)
            {
                num2++;
                if (num % num2 == 0)
                    Console.Write(num2 + "\t");

            }
            Console.WriteLine();
        }

        static void Actions()
        {
            while (true)
            {
                Console.WriteLine("1) Игра угадай число");
                Console.WriteLine("2) Таблица умножения");
                Console.WriteLine("3) Найти делители числа");
                Console.WriteLine("4) Выйти из программы");
                Console.WriteLine("Введите действие: ");
                int action = Convert.ToInt32(Console.ReadLine());
                if (action == 1)
                {
                    GuessNum();
                }
                else if (action == 2)
                {
                    MultiTab();
                }
                else if (action == 3)
                {
                    Console.WriteLine("Введите число: ");
                    Delitel();
                }
                else if (action == 4)
                {
                    break;
                }
            }
        }
    }
}
    


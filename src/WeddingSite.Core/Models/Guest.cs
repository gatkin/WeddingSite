namespace WeddingSite.Core
{
    public class Guest
    {
        public int Id { get; set; }

        public string Name { get; set; } 

        public GuestStatus Status { get; set; } = GuestStatus.Unregistered;
    }
}
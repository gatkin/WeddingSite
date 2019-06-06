namespace WeddingSite.Core
{
    public class Guest
    {
        public string Id { get; set; }

        public string Name { get; set; } 

        public GuestStatus Status { get; set; } = GuestStatus.Unregistered;
    }
}
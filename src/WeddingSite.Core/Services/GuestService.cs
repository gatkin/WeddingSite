using System.Collections.Generic;
using System.Linq;

namespace WeddingSite.Core
{
    public class GuestService : IGuestService
    {
        private static readonly IEnumerable<Guest> Guests = new []
        {
            new Guest{ Name = "John Doe" },
            new Guest{ Name = "Jane Doe" },
            new Guest{ Name = "Phillip J Fry" },
        };

        private static readonly IEnumerable<(Guest, Guest)> PlusOnePairs = new []
        {
            (Guests.ElementAt(0), Guests.ElementAt(1)),
        };

        public IEnumerable<Guest> GetAllGuests()
        {
            return Guests;
        }

        public IEnumerable<(Guest, Guest)> GetAllPlusOnePairs()
        {
            return PlusOnePairs;
        }
    }
}
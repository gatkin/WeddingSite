using System.Collections.Generic;
using System.Linq;

namespace WeddingSite.Core
{
    public class GuestService : IGuestService
    {
        private static readonly IEnumerable<Guest> Guests = new []
        {
            new Guest{ Name = "John Doe", Id = "1" },
            new Guest{ Name = "Jane Doe", Id = "2" },
            new Guest{ Name = "Philip J Fry", Id = "3" },
            new Guest{ Name = "Turanga Leela", Id = "4" },
            new Guest{ Name = "Zapp Brannigan", Id = "5" },
            new Guest{ Name = "Kif Kroker", Id = "6" },
            new Guest{ Name = "Hermes Conrad", Id = "7" },
            new Guest{ Name = "Bender Bending Rodrigez", Id = "8" },
            new Guest{ Name = "Amy Wang", Id = "9" },
            new Guest{ Name = "Zoidberg" , Id = "10" },
        };

        private static readonly IEnumerable<PlusOnePair> PlusOnePairs = new []
        {
            new PlusOnePair("1", "2"),
            new PlusOnePair("3", "4"),
            new PlusOnePair("6", "9"),
        };

        public IEnumerable<Guest> GetAllGuests()
        {
            return Guests;
        }

        public IEnumerable<PlusOnePair> GetAllPlusOnePairs()
        {
            return PlusOnePairs;
        }
    }
}
using System.Collections.Generic;

namespace WeddingSite.Core
{
    public interface IGuestService
    {
        IEnumerable<Guest> GetAllGuests();

        IEnumerable<PlusOnePair> GetAllPlusOnePairs();
    }
}
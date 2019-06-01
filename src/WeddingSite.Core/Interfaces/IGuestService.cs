using System.Collections.Generic;

namespace WeddingSite.Core
{
    public interface IGuestService
    {
        IEnumerable<Guest> GetAllGuests();

        IEnumerable<(Guest, Guest)> GetAllPlusOnePairs();
    }
}
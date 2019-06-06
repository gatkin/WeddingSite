using System.Collections.Generic;
using System.Threading.Tasks;

namespace WeddingSite.Core
{
    public interface IGuestService
    {
        Task<IEnumerable<Guest>> GetAllGuestsAsync();

        Task<IEnumerable<PlusOnePair>> GetAllPlusOnePairsAsync();
    }
}
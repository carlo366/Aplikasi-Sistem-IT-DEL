<?php

namespace App\Http\Controllers;

use App\Models\RequestizinBermalam;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class RequestizinBermalamController extends Controller
{
    public function index()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil data RequestIzinBermalam sesuai dengan user yang login
        $izinBermalamData = RequestizinBermalam::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response([
            'RequestIzinBermalam' => $izinBermalamData
        ], 200);
    }
    public function show($id)
    {
        return response([
            'RequestIzinBermalam' => RequestizinBermalam::where('id', $id)->get()
        ], 200);
    }



public function indexadmin()
{
    // $user = Auth::user();

    // Mengambl data RequestIzinBermalam dengan status "pending"
    $izinBermalamData = RequestizinBermalam::where('status', 'pending')
        ->orderBy('created_at', 'desc')
        ->get();

    return response([
        'RequestIzinBermalam' => $izinBermalamData
    ], 200);
}


    public function store(Request $request)
    {
        $rules = [
            'tujuan' => 'required|string',
            'reason' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => [
                'required',
                'date',
                'after:start_date',
                function ($attribute, $value, $fail) use ($request) {
                    $startDateTime = Carbon::parse($request->input('start_date'));
                    $endDateTime = Carbon::parse($value);
                    $dayOfWeekStart = $startDateTime->dayOfWeek;
                    $dayOfWeekEnd = $endDateTime->dayOfWeek;
                    $startTime = $startDateTime->format('H:i');
                    $endTime = $endDateTime->format('H:i');

                    if (
                        !(
                            ($dayOfWeekStart == Carbon::FRIDAY && $startTime >= '17:00') ||
                            ($dayOfWeekStart == Carbon::SATURDAY && ($startTime >= '08:00' && $startTime <= '17:00'))
                        )
                    ) {
                        $fail('Tanggal mulai harus pada hari Jumat jam 17.00 sampai seterusnya atau hari Sabtu jam 08.00 sampai jam 17.00.');
                    }

                    if (
                        !(
                            ($dayOfWeekEnd == Carbon::FRIDAY && $endTime >= '17:00') ||
                            ($dayOfWeekEnd == Carbon::SATURDAY && ($endTime >= '08:00' && $endTime <= '17:00'))
                        )
                    ) {
                        $fail('Tanggal berakhir harus pada hari Jumat jam 17.00 sampai seterusnya atau hari Sabtu jam 08.00 sampai jam 17.00.');
                    }
                },
            ],
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        // Lanjutkan dengan membuat permintaan izin bermalam
        $user = RequestizinBermalam::create([
            'tujuan' => $request->input('tujuan'),
            'reason' => $request->input('reason'),
            'start_date' => $request->input('start_date'),
            'end_date' => $request->input('end_date'),
            'user_id' => auth()->user()->id,
        ]);

        return response([
            'message' => 'Request Izin Bermalam dibuat',
            'RequestIzinBermalam' => $user,
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $requestIzinBermalam = RequestizinBermalam::find($id);

        if (!$requestIzinBermalam) {
            return response([
                'message' => 'Request Izin Bermalam Tidak Ditemukan',
            ], 404);
        }

        if ($requestIzinBermalam->user_id != auth()->user()->id) {
            return response([
                'message' => 'Akun Anda Tidak memiliki akses',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'tujuan' => 'required|string',
            'reason' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => [
                'required',
                'date',
                'after:start_date',
                function ($attribute, $value, $fail) use ($request) {
                    $startDateTime = Carbon::parse($request->input('start_date'));
                    $endDateTime = Carbon::parse($value);
                    $dayOfWeekStart = $startDateTime->dayOfWeek;
                    $dayOfWeekEnd = $endDateTime->dayOfWeek;
                    $startTime = $startDateTime->format('H:i');
                    $endTime = $endDateTime->format('H:i');

                    if (
                        !(
                            ($dayOfWeekStart == Carbon::FRIDAY && $startTime >= '17:00') ||
                            ($dayOfWeekStart == Carbon::SATURDAY && ($startTime >= '08:00' && $startTime <= '17:00'))
                        )
                    ) {
                        $fail('Tanggal mulai harus pada hari Jumat jam 17.00 sampai seterusnya atau hari Sabtu jam 08.00 sampai jam 17.00.');
                    }

                    if (
                        !(
                            ($dayOfWeekEnd == Carbon::FRIDAY && $endTime >= '17:00') ||
                            ($dayOfWeekEnd == Carbon::SATURDAY && ($endTime >= '08:00' && $endTime <= '17:00'))
                        )
                    ) {
                        $fail('Tanggal berakhir harus pada hari Jumat jam 17.00 sampai seterusnya atau hari Sabtu jam 08.00 sampai jam 17.00.');
                    }
                },
            ],
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        // Lanjutkan dengan melakukan update
        $requestIzinBermalam->update([
            'tujuan' => $request->input('tujuan'),
            'reason' => $request->input('reason'),
            'start_date' => $request->input('start_date'),
            'end_date' => $request->input('end_date'),
        ]);

        return response([
            'message' => 'Request Izin Bermalam Telah Diupdate',
            'requestIzinBermalam' => $requestIzinBermalam,
        ], 200);
    }

   public function destroy($id){
    $RequestIzinBermalam= RequestizinBermalam::find($id);
    if(!$RequestIzinBermalam){
     return response([
         'message' => 'Request Izin Bermalam Tidak Ditemukan',
     ], 403);
    }
    if($RequestIzinBermalam->user_id !=auth()->user()->id){
     return response([
         'message' => 'Akun Anda Tidak mengakses Ini',
     ], 403);
    }
    $RequestIzinBermalam->delete();
    return response([
        'message' => 'Request Izin Bermalam Telah Dihapus',
        'RequestIzinBermalam'=>$RequestIzinBermalam
    ], 200);
   }

   public function approve($id)
   {
       $requestIzinBermalam = RequestIzinBermalam::find($id);

       if (!$requestIzinBermalam) {
           return response([
               'message' => 'Request Izin Bermalam Tidak Ditemukan',
           ], 404);
       }

       // Lakukan logika approve, misalnya mengubah status menjadi "approved"
       $requestIzinBermalam->status = 'approved';
       $requestIzinBermalam->save();

       return response([
           'message' => 'Permintaan Izin Bermalam Telah Disetujui',
           'requestIzinBermalam' => $requestIzinBermalam,
       ], 200);
   }


   public function reject($id)
   {
       $requestIzinBermalam = RequestIzinBermalam::find($id);

       if (!$requestIzinBermalam) {
           return response([
               'message' => 'Request Izin Bermalam Tidak Ditemukan',
           ], 404);
       }

       // Lakukan logika reject, misalnya mengubah status menjadi "rejected"
       $requestIzinBermalam->status = 'rejected';
       $requestIzinBermalam->save();

       return response([
           'message' => 'Permintaan Izin Bermalam Telah Ditolak',
           'requestIzinBermalam' => $requestIzinBermalam,
       ], 200);
   }

}



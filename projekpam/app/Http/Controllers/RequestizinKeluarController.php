<?php

namespace App\Http\Controllers;

use App\Models\RequestIzinKeluar;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class RequestIzinKeluarController extends Controller
{
    public function index()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil semua data RequestIzinKeluar sesuai dengan user yang login
        $izinKeluarData = RequestIzinKeluar::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response([
            'RequestIzinKeluar' => $izinKeluarData
        ], 200);
    }


public function indexadmin()
{
    // $user = Auth::user();

    // Mengambl data RequestIzinKeluar dengan status "pending"
    $izinKeluarData = RequestIzinKeluar::where('status', 'pending')
        ->orderBy('created_at', 'desc')
        ->get();

    return response([
        'RequestIzinKeluar' => $izinKeluarData
    ], 200);
}

    public function store(Request $request)
    {

        $rules = [
            'reason' => 'required|string',
            'start_date' => 'required',
            'end_date' =>'required',
        ];
        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $user = RequestIzinKeluar::create([
            'reason' => $request->input('reason'),
            'start_date' => $request->input('start_date'),
            'end_date' => $request->input('end_date'),
            'user_id' => auth()->user()->id
        ]);
        return response([

            'message' => 'Request Izin Keluar dibuat',
            'RequestIzinKeluar'=>$user
        ], 200);
    }

    public function update(Request $request,$id)
    {
        $RequestIzinKeluar= RequestIzinKeluar::find($id);
       if(!$RequestIzinKeluar){
        return response([
            'message' => 'Request Izin Keluar Tidak Ditemukan',
        ], 403);
       }
       if($RequestIzinKeluar->user_id !=auth()->user()->id){
        return response([
            'message' => 'Akun Anda Tidak mengakses Ini',
        ], 403);
       }
       $validator = Validator::make($request->all(), [
        'reason' => 'required|string',
        'start_date' => 'required|date',
        'end_date' => 'required|date',
    ]);

    if ($validator->fails()) {
        return response()->json($validator->errors(), 400);
    }
       $RequestIzinKeluar->update([
         'reason' => $request->input('reason'),
        'start_date' => $request->input('start_date'),
        'end_date' => $request->input('end_date'),
    ]);
    return response([
        'message' => 'Request Izin Keluar Telah Diupdate',
        'RequestIzinKeluar'=>$RequestIzinKeluar
    ], 200);
    }

   public function destroy($id){
    $RequestIzinKeluar= RequestIzinKeluar::find($id);
    if(!$RequestIzinKeluar){
     return response([
         'message' => 'Request Izin Keluar Tidak Ditemukan',
     ], 403);
    }
    if($RequestIzinKeluar->user_id !=auth()->user()->id){
     return response([
         'message' => 'Akun Anda Tidak mengakses Ini',
     ], 403);
    }
    $RequestIzinKeluar->delete();
    return response([
        'message' => 'Request Izin Keluar Telah Dihapus',
        'RequestIzinKeluar'=>$RequestIzinKeluar
    ], 200);
   }

   public function approve($id)
{
    $requestIzinKeluar = RequestIzinKeluar::find($id);

    if (!$requestIzinKeluar) {
        return response([
            'message' => 'Request Izin Keluar Tidak Ditemukan',
        ], 404);
    }

    // Lakukan logika approve, misalnya mengubah status menjadi "approved"
    $requestIzinKeluar->status = 'approved';
    $requestIzinKeluar->save();

    return response([
        'message' => 'Permintaan Izin Keluar Telah Disetujui',
        'requestIzinKeluar' => $requestIzinKeluar,
    ], 200);
}


public function reject($id)
{
    $requestIzinKeluar = RequestIzinKeluar::find($id);

    if (!$requestIzinKeluar) {
        return response([
            'message' => 'Request Izin Keluar Tidak Ditemukan',
        ], 404);
    }

    // Lakukan logika reject, misalnya mengubah status menjadi "rejected"
    $requestIzinKeluar->status = 'rejected';
    $requestIzinKeluar->save();

    return response([
        'message' => 'Permintaan Izin Keluar Telah Ditolak',
        'requestIzinKeluar' => $requestIzinKeluar,
    ], 200);
}

}


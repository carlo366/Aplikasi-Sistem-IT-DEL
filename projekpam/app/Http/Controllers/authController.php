<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class authController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function registerUser(Request $request){
        $datauser = new User();
        $rules = [
            'ktp' => 'required|max:13',
            'nim' => 'required',
            'fullname' => 'required',
            'phone' => 'required',
            'email'=>'required|email|unique:users,email',
            'password' => 'required|string|min:6',
        ];

        $validator = Validator::make($request->all(),$rules);
        if($validator->fails()){
            return Response()->json([
                'status'=>false,
                'message'=>'gagal',
                'data'=>$validator->errors()
            ],401);
        }

        $datauser->ktp = $request->ktp;
        $datauser->nim = $request->nim;
        $datauser->fullname = $request->fullname;
        $datauser->phone = $request->phone;
        $datauser->email = $request->email;
        $datauser->password = Hash::make($request->password);
        $datauser->save();

        $token = $datauser->createToken('Personal Access Token')->plainTextToken;
        $response = ['user'=> $datauser,'token'=>$token];
        return response()->json($response,200);
        return response()->json([

            'status'=>true,
            'message'=>'berhasil memasukkan data baru',
        ],200);
    }

    public function loginUser(Request $request){
        $rules = [
            'email'=>'required|email',
            'password' => 'required|string  ',
        ];

        $request->validate($rules);

        $datauser = User::where('email',$request->email)->first();

        if($datauser && Hash::check($request->password,$datauser->password)){
            $token = $datauser->createToken('personal akses Token')->plainTextToken;
            $response=['user'=>$datauser,'token'=>$token];
            return response()->json($response,200);
        }
        $response = ['message'=>'incorect email or password'];
        return response()->json($response,400);
    }
}

        // $validator = Validator::make($request->all(),$rules);
        // if($validator->fails()){
        //     return Response()->json([
        //         'status'=>false,
        //         'message'=>'login gagal',
        //         'data'=>$validator->errors()
        //     ],401);
        // }

        // if(!Auth::attempt($request->only(['email','password']))){
        //     return response()->json([
        //         'status'=>false,
        //         'message'=>'email dan password tidak sesuai',
        //     ],400);
        // }

        // $datauser = User::where('email',$request->email)->first();
        // return response()->json([
        //     'status',true,
        //     'message','berhasil login',
        //     'token'=>$datauser->createToken('api-product')->plainTextToken
        // ]);
    // }
// }

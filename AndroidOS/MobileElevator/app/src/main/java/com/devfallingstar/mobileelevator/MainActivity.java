package com.devfallingstar.mobileelevator;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.Spinner;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;

public class MainActivity extends AppCompatActivity implements Button.OnClickListener {

    int deptF=1, arriveF=1;

    private Socket socket;

    private BufferedReader in;
    private PrintWriter out;

    private int port = 9999;
    private String ip = "192.168.10.102";

    @Override
    protected void onStop() {
        super.onStop();
        try {
            socket.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    port = 9999;
                    setSocket(ip, port);
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
        }).start();

        Spinner departS = (Spinner) findViewById(R.id.depart);
        Spinner arriveS = (Spinner) findViewById(R.id.arrive);
        Button reqBtn = (Button) findViewById(R.id.reqeustBtn);

        departS.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener(){
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
                deptF = position;
            }
            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        arriveS.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener(){
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
                arriveF = position;
            }
            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        reqBtn.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.reqeustBtn:
                try {
                    sendReqeust();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                break;
            default:
                break;
        }
    }

    public void sendReqeust() throws IOException {
        new Thread(new Runnable() {
            @Override
            public void run() {
                String result;
                String request;

                request = (deptF) + ":" + (arriveF) + ":5";
                Log.d("네트워크", request);

                out.write(request+"\n");
                out.flush();
                Log.d("네트워크 전송 후", request);
//                    result = in.readLine();
//                    if(result.contains("RECV")){
//                        return;
//                    }else{
//
//                    }
            }
        }).start();
    }

    public void setSocket(String ip, int port) throws IOException {

        try {
            socket = new Socket(ip, port);
            out = new PrintWriter(socket.getOutputStream());
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        } catch (IOException e) {
            System.out.println(e);
            e.printStackTrace();
        }
    }

}

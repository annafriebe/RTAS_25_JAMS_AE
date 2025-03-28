#include <mpc/NLMPC.hpp>
#include <mpc/Utils.hpp>
#include <cmath>
#include <pthread.h>
#include <sched.h>

struct Obstacle
{
    mpc::cvec<2> pos;
    double radius;
};

int main()
{
    
    pthread_t this_thread = pthread_self();
    struct sched_param s_params;
    s_params.sched_priority = sched_get_priority_max(SCHED_FIFO);
    int ret = pthread_setschedparam(this_thread, SCHED_FIFO, &s_params);
    if (ret != 0){
        std::cerr << "Unable to set sched attr" << std::endl;
    }
    else{
        std::cerr << "Sched params set" << std::endl;
    }
    int policy = 0;
    ret = pthread_getschedparam(this_thread, &policy, &s_params);
    if (ret != 0){
        std::cerr << "Could not retrieve sched params" << std::endl;
        return 0;
    }
    if (policy != SCHED_FIFO){
        std::cerr << "Could not set FIFO sched" << std::endl;
    }
    cpu_set_t set2;
    CPU_ZERO(&set2);
    CPU_SET(2, &set2);
    ret = pthread_setaffinity_np(this_thread, sizeof(set2), &set2);
    if (ret < 0){
        std::cerr << "set affinity failed" << std::endl;
    }
    constexpr int n_obs = 12;

    constexpr int Tnx = 4;
    constexpr int Tnu = 2;
    constexpr int Tny = 4;
    constexpr int Tph = 6;
    constexpr int Tch = 6;
    constexpr int Tineq = (Tph + 1) * n_obs;
    constexpr int Teq = 0;

    // list of n_obs obstacles
    Obstacle obs[n_obs];
    mpc::cvec<2> yref, v_pref;
    mpc::cvec<Tnx> m_x, m_x_next;

    double Ts = 0.08;

    mpc::NLMPC<Tnx, Tnu, Tny, Tph, Tch, Tineq, Teq> controller;
    controller.setLoggerLevel(mpc::Logger::log_level::NORMAL);

    mpc::mat<Tnx, Tnx> A(Tnx, Tnx);
    mpc::mat<Tnx, Tnu> B(Tnx, Tnu);
    mpc::mat<Tny, Tnx> C(Tny, Tnx);
    mpc::mat<Tny, Tnu> D(Tny, Tnu);

    double m = 1.0;
    double r = 0.15;
    double speed = 1.0;

    A.setZero();
    A.block(0, 2, 2, 2).setIdentity();

    B.setZero();
    B.block(2, 0, 2, 2).setIdentity();
    B = B * 1.0/m;

    C.setIdentity();
    D.setZero();

    // discrete time model of the system
    mpc::mat<Tnx, Tnx> Ad(Tnx, Tnx);
    mpc::mat<Tnx, Tnu> Bd(Tnx, Tnu);
    mpc::mat<Tny, Tnx> Cd(Tny, Tnx);
    mpc::mat<Tny, Tnu> Dd(Tny, Tnu);

    mpc::discretization<Tnx,Tnu,Tny>(A, B, C, D, Ts, Ad, Bd, Cd, Dd);

    auto stateEq = [&](
                       mpc::cvec<Tnx> &dx,
                       const mpc::cvec<Tnx> &x,
                       const mpc::cvec<Tnu> &u,
                       const unsigned int &)
    {
        dx = Ad * x + Bd * u;
    };
    controller.setStateSpaceFunction(stateEq);

    auto outEq = [&](
                     mpc::cvec<Tny> &y,
                     const mpc::cvec<Tnx> &x,
                     const mpc::cvec<Tnu> &u,
                     const unsigned int &)
    {
        y = Cd * x + Dd * u;
    };
    controller.setOutputFunction(outEq);

    auto objEq = [&](
                     const mpc::mat<Tph + 1, Tnx> &x,
                     const mpc::mat<Tph + 1, Tny> &y,
                     const mpc::mat<Tph + 1, Tnu> &u,
                     const double &e)
    {
        double cost = 0;
        for (int i = 0; i < Tph + 1; i++)
        {
            cost += 1e3 * (x.row(i).segment(2, 2).transpose() - v_pref).squaredNorm();
            cost += 1e-2 * u.row(i).squaredNorm();
        }

        cost += 1e-5 * e * e;
        return cost;
    };
    controller.setObjectiveFunction(objEq);

    auto conIneq = [&](
                       mpc::cvec<Tineq> &ineq,
                       const mpc::mat<Tph + 1, Tnx> &x,
                       const mpc::mat<Tph + 1, Tny> &y,
                       const mpc::mat<Tph + 1, Tnu> &u,
                       const double &)
    {
        int index = 0;
        for (int i = 0; i < Tph + 1; i++)
        {
            for (size_t j = 0; j < n_obs; j++)
            {
                mpc::cvec<2> r_pos = x.row(i).segment(0,2).transpose() - obs[j].pos;
                ineq(index++) = obs[j].radius - r_pos.norm();
            }
        }
    };
    controller.setIneqConFunction(conIneq);

    // set current state
    m_x.setZero();
    m_x_next.setZero();

    obs[0].pos << -2.0, -2.0;
    obs[0].radius = 0.5;

    obs[1].pos << 2.0, 2.0;
    obs[1].radius = 0.5;

    obs[2].pos << -2.0, 2.0;
    obs[2].radius = 0.5;

    obs[3].pos << 2.0, -2.0;
    obs[3].radius = 0.5;

    obs[4].pos << -2.0, 0.0;
    obs[4].radius = 0.5;

    obs[5].pos << 2.0, 0.0;
    obs[5].radius = 0.5;

    obs[6].pos << 0.0, 2.0;
    obs[6].radius = 0.5;

    obs[7].pos << 0.0, -2.0;
    obs[7].radius = 0.5;

    obs[8].pos << 1.0, 1.0;
    obs[8].radius = 0.3;

    obs[9].pos << -1.0, -1.0;
    obs[9].radius = 0.3;

    obs[10].pos << -1.0, 1.0;
    obs[10].radius = 0.3;

    obs[11].pos << -1.0, 1.0;
    obs[11].radius = 0.3;


    
    // set the reference position
    yref << 3.0, 2.0;
    
    std::vector<double> yref_1_list = {3, 0, -3, 0, 3, 0};
    std::vector<double> yref_2_list = {2, 3, 0, -3, -2, 0};
    
    int yref_ind = 0;

    mpc::NLParameters params;
    params.maximum_iteration = 200;
    params.absolute_xtol = 1e-6;
    params.hard_constraints = false;

    controller.setOptimizerParameters(params);

    auto res = controller.getLastResult();
    res.cmd.setZero();

    double t = 0;
    for(int i = 0; i < 5000; i++)
    {
        // solve
        res = controller.optimize(m_x, res.cmd);
        
        // apply vector field
        stateEq(m_x_next, m_x, res.cmd, -1);
        m_x = m_x_next;
        t += Ts;

        v_pref = (yref - m_x.segment(0, 2)).normalized() * speed;

        if((m_x.segment(0,2) - yref).norm() < 0.05)
        {
            yref_ind = (yref_ind + 1) % yref_1_list.size();
            yref << yref_1_list[yref_ind], yref_2_list[yref_ind];
        }
     }

    std::cout << controller.getExecutionStats();

    return 0;
}
